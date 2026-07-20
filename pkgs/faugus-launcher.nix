{
  faugus-launcher,
  gobject-introspection,
  gtk4,
  lib,
  libadwaita,
  libmanette,
  lsfg-vk,
  python3Packages,
  umu-launcher,
  version,
  src,
  wrapGAppsHook4,
}:
faugus-launcher.overrideAttrs {
  inherit version src;

  nativeBuildInputs = (faugus-launcher.nativeBuildInputs or []) ++ [
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = (faugus-launcher.buildInputs or []) ++ [
    gtk4
    libadwaita
    libmanette
  ];

  postPatch = ''
    substituteInPlace faugus-launcher \
      --replace-fail "/usr/bin/python3" "${python3Packages.python.interpreter}"

    substituteInPlace faugus/path_manager.py \
      --replace-fail "/usr/lib/extensions/vulkan/lsfgvk/lib/liblsfg-vk.so" "${lsfg-vk}/lib/liblsfg-vk.so" \
      --replace-fail "/usr/lib/liblsfg-vk.so" "${lsfg-vk}/lib/liblsfg-vk.so" \
      --replace-fail "PathManager.user_data('faugus-launcher/umu-run')" "'${lib.getExe umu-launcher}'"
  '';
}
