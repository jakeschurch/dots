{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  xz,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libGL,
  libnotify,
  libpulseaudio,
  libusb1,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  bubblewrap,
  git,
  systemd,
  xorg,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "chatgpt";
  version = "26.917.71314";

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
    hash = "sha256-hR7Ci2W94v8dqfN9zfW24gqRXHVo+LLOmTwAQo8BiuU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    xz
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libGL
    libnotify
    libpulseaudio
    libusb1
    libxkbcommon
    mesa
    nspr
    nss
    pango
    stdenv.cc.cc
    systemd
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
  ];

  unpackPhase = ''
    ar x "$src"
    tar -xJf data.tar.xz
  '';

  installPhase = ''
    mkdir -p "$out"
    cp -R usr/lib "$out/lib"
    cp -R usr/share "$out/share"

    mkdir -p "$out/bin"
    makeWrapper "$out/lib/chatgpt/codex-launcher" "$out/bin/chatgpt" \
      --prefix PATH : ${
        lib.makeBinPath [
          bubblewrap
          git
        ]
      }

    substituteInPlace "$out/share/applications/chatgpt.desktop" \
      --replace-fail "Exec=chatgpt" "Exec=$out/bin/chatgpt"
  '';

  meta = {
    description = "ChatGPT desktop application";
    homepage = "https://developers.openai.com/codex/linux/linux-app";
    license = lib.licenses.unfree;
    mainProgram = "chatgpt";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
