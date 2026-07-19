{system ? builtins.currentSystem}: let
  packages = (import ./.).outputs.packages;
in {
  inherit
    (packages.${system})
    faugus-launcher
    linux_cachyos-lto-v3
    ;
}
