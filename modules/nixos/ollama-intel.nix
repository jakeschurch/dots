{
  pkgs,
  ...
}:
{
  # Intel Arc B60 Pro - Ollama via IPEX-LLM native package
  # Runs on port 11435 to coexist with NVIDIA Ollama on 11434
  systemd.services.ollama-intel = {
    description = "Ollama with IPEX-LLM for Intel Arc GPU";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "simple";
      User = "jake";
      Group = "users";
      # Use ollama-bin directly since it works
      ExecStart = "${pkgs.ollama-ipex-llm}/bin/ollama-ipex-llm serve";
      Restart = "on-failure";
      RestartSec = "5s";

      # GPU access
      SupplementaryGroups = [
        "video"
        "render"
      ];

      # # Environment variables (using serviceConfig.Environment for better control)
      Environment = [
        # Library paths for SYCL/Level Zero (critical for B60 GPU detection)
        "LD_LIBRARY_PATH=${pkgs.intel-graphics-compiler}/lib:${pkgs.intel-compute-runtime.drivers}/lib:${pkgs.ollama-ipex-llm}/lib"

        # Ollama core settings
        "OLLAMA_HOST=127.0.0.1:11435"
        "OLLAMA_MODELS=/home/jake/.ollama/models"
        "OLLAMA_NUM_GPU=999"
        "OLLAMA_FLASH_ATTENTION=0"
        "OLLAMA_NUM_PARALLEL=1"
        "OLLAMA_KEEP_ALIVE=10m"
        "OLLAMA_NUM_CTX=15000"
        "SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1"

        # Intel GPU & oneAPI settings
        "ONEAPI_DEVICE_SELECTOR=level_zero:gpu"
        "ZES_ENABLE_SYSMAN=1"
        "SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1"
        "SYCL_ENABLE_PCI=1"
        "SYCL_PI_LEVEL_ZERO_DEVICE_SCOPE=0"
        "ZE_ENABLE_ALT_DRIVERS=${pkgs.intel-compute-runtime.drivers}/lib/libze_intel_gpu.so.1"

        # IPEX-LLM specific
        "IPEX_LLM_QUANTIZE_KV_CACHE=1"

        # Misc
        "no_proxy=localhost,127.0.0.1"
      ];
    };
  };

  # Add jake to video and render groups for GPU access
  users.users.jake.extraGroups = [
    "video"
    "render"
  ];
}
