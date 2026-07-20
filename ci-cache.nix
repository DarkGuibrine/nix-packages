{system ? builtins.currentSystem}: let
  packages = (import ./.).outputs.packages.${system};
in {
  inherit
    (packages)
    netbird
    netbird-ui
    ;
} // (if system == "x86_64-linux" then {
  inherit
    (packages)
    faugus-launcher
    hydralauncher
    linux_cachyos-lto-v3
    ;
} else {})
