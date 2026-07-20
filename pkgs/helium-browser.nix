{
  lib,
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  version,
  src,
  alsa-lib,
  at-spi2-core,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  glib,
  gtk3,
  libdrm,
  libGL,
  libva,
  libx11,
  libxcomposite,
  libxcb,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxtst,
  mesa,
  nspr,
  nss,
  pango,
  pipewire,
  vulkan-loader,
  wayland,
}: let
  libPath = lib.makeLibraryPath [
    libva
    pipewire
    wayland
    gtk3
    libGL
    vulkan-loader
    libx11
    libxcb
  ];
in
  stdenv.mkDerivation {
    pname = "helium-browser";
    inherit version src;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = [
      alsa-lib
      at-spi2-core
      cups
      dbus
      expat
      fontconfig
      freetype
      glib
      gtk3
      libdrm
      libGL
      libva
      libx11
      libxcomposite
      libxcb
      libxdamage
      libxext
      libxfixes
      libxi
      libxkbcommon
      libxrandr
      libxrender
      libxscrnsaver
      libxtst
      mesa
      nspr
      nss
      pango
      pipewire
      vulkan-loader
      wayland
    ];

    autoPatchelfIgnoreMissingDeps = [
      "libqtpo.so"
      "libQt5Core.so.5"
      "libQt5Gui.so.5"
      "libQt5Widgets.so.5"
      "libQt6Core.so.6"
      "libQt6Gui.so.6"
      "libQt6Widgets.so.6"
    ];

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/helium
      cp -r ./* $out/lib/helium/

      mkdir -p $out/bin
      makeWrapper $out/lib/helium/helium $out/bin/helium \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
        --set LD_LIBRARY_PATH "$out/lib/helium${lib.optionalString (libPath != "") ":${libPath}"}"

      if [ -d share ]; then
        cp -r share $out/
      fi

      runHook postInstall
    '';

    meta = with lib; {
      description = "Private, fast, and honest web browser";
      homepage = "https://helium.computer";
      license = licenses.gpl3Plus;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      mainProgram = "helium";
    };
  }
