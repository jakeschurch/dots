{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  ocl-icd,
  level-zero,
  intel-compute-runtime,
  intel-graphics-compiler,
  intel-media-driver,
  intel-gmmlib,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "ollama-ipex-llm";
  version = "2.3.0b20250725";

  src = fetchurl {
    url = "https://github.com/ipex-llm/ipex-llm/releases/download/v2.3.0-nightly/ollama-ipex-llm-${version}-ubuntu.tgz";
    hash = "sha256-zTWGTyiNERLpJDN2hgcHx7AtDMb2JEbjWTAZ3VMMfIc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib # libstdc++
    ocl-icd # libOpenCL
    level-zero # Level Zero loader
    intel-compute-runtime
    intel-compute-runtime.drivers
    intel-graphics-compiler
    intel-media-driver
    intel-gmmlib
    zlib # libz
  ];

  # Libraries bundled in the package that autoPatchelfHook should find
  appendRunpaths = [ "$out/lib" ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib}
    cd ollama-ipex-llm-${version}-ubuntu

    # Install libraries (including Unified Runtime libs for GPU)
    cp -v *.so* $out/lib/
    # Use haswell variant - more compatible with both Intel and AMD CPUs
    ln -sf libggml-cpu-haswell.so $out/lib/libggml-cpu.so

    # Install binaries - keep originals with -real suffix
    cp -v ollama $out/bin/ollama-real
    cp -v ollama-bin $out/bin/ollama-bin-real
    cp -v ollama-lib $out/bin/ollama-lib-real
    cp -v ls-sycl-device ls-sycl-device-bin llamafile $out/bin/ || true

    # Common wrapper args for Intel GPU
    wrapperArgs=(
      --prefix LD_LIBRARY_PATH : "${intel-graphics-compiler}/lib"
      --prefix LD_LIBRARY_PATH : "${intel-compute-runtime.drivers}/lib"
      --prefix LD_LIBRARY_PATH : "$out/lib"
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"
      --set ZE_ENABLE_ALT_DRIVERS "${intel-compute-runtime.drivers}/lib/libze_intel_gpu.so.1"
      --set ONEAPI_DEVICE_SELECTOR "level_zero:gpu"
      --set ZES_ENABLE_SYSMAN "1"
      --set SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS "1"
      --set OLLAMA_NUM_GPU "999"
      --set OLLAMA_FLASH_ATTENTION "0"
    )

    # Wrap ollama-lib (spawned by ollama for inference)
    makeWrapper $out/bin/ollama-lib-real $out/bin/ollama-lib "''${wrapperArgs[@]}"

    # Wrap ollama-bin (spawned by ollama for serving)
    makeWrapper $out/bin/ollama-bin-real $out/bin/ollama-bin "''${wrapperArgs[@]}"

    # Wrap the main ollama binary
    makeWrapper $out/bin/ollama-real $out/bin/ollama "''${wrapperArgs[@]}"

    # Create ollama-ipex-llm as the main entrypoint
    ln -s $out/bin/ollama $out/bin/ollama-ipex-llm

    runHook postInstall
  '';

  meta = with lib; {
    description = "Ollama with IPEX-LLM for Intel GPUs";
    homepage = "https://github.com/ipex-llm/ipex-llm";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "ollama-ipex-llm";
  };
}
