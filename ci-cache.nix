{system ? builtins.currentSystem}: let
  packages = (import ./.).outputs.packages;
in {
  inherit
    (packages.${system})
    faugus-launcher
    hydralauncher
    linux_cachyos-lto-v3
    netbird
    netbird-ui
    ;
}
