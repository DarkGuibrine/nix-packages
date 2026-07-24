{lib, ...}: {
  perSystem = {
    inputs',
    nvfetcherSources,
    pkgs,
    self',
    system,
    ...
  }: {
    packages = {
      hydralauncher = pkgs.callPackage ../pkgs/hydralauncher.nix {
        inherit (nvfetcherSources.hydralauncher) version src;
      };

      netbird = pkgs.callPackage ../pkgs/netbird.nix {
        inherit (nvfetcherSources.netbird) version src;
        vendorHash = "sha256-5urO9yKeRYM/z5YdLF2+NhbD9CWzGbB5tO37scBK5uo=";
      };

      netbird-ui = pkgs.callPackage ../pkgs/netbird.nix {
        inherit (nvfetcherSources.netbird) version src;
        vendorHash = "sha256-5urO9yKeRYM/z5YdLF2+NhbD9CWzGbB5tO37scBK5uo=";
        componentName = if lib.hasPrefix "aarch64" system then "client" else "ui";
      };

      dwproton = pkgs.callPackage ../pkgs/proton-bin.nix {
        pname = "dwproton";
        version = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.dwproton-x64-linux.version;
        };
        src = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.dwproton-x64-linux.src;
        };
      };

      faugus-launcher = pkgs.callPackage ../pkgs/faugus-launcher.nix {
        inherit (nvfetcherSources.faugus-launcher) version src;
      };

helium-browser = pkgs.callPackage ../pkgs/helium-browser.nix {
        version = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.helium-browser-x64-linux.version;
          aarch64-linux = nvfetcherSources.helium-browser-arm64-linux.version;
        };
        src = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.helium-browser-x64-linux.src;
          aarch64-linux = nvfetcherSources.helium-browser-arm64-linux.src;
        };
      };

      nvfetcher = pkgs.nvfetcher.overrideAttrs {
        inherit (nvfetcherSources.nvfetcher) version src;
      };

      proton-cachyos = pkgs.callPackage ../pkgs/proton-bin.nix {
        pname = "proton-cachyos";
        version = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.proton-cachyos-x64-linux.version;
        };
        src = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.proton-cachyos-x64-linux.src;
        };
      };

      proton-cachyos-v3 = pkgs.callPackage ../pkgs/proton-bin.nix {
        pname = "proton-cachyos-v3";
        version = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.proton-cachyos-x64-linux-v3.version;
        };
        src = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.proton-cachyos-x64-linux-v3.src;
        };
      };

      proton-ge = pkgs.callPackage ../pkgs/proton-bin.nix {
        pname = "proton-ge";
        version = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.proton-ge-x64-linux.version;
        };
        src = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.proton-ge-x64-linux.src;
        };
      };
    };
  };
}
