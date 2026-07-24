{
  buildGoModule,
  fetchFromGitHub,
  lib,
  stdenv,
  versionCheckHook,
  installShellFiles,
  pkg-config,
  gtk3,
  gtk4,
  libayatana-appindicator,
  libsoup_3,
  libx11,
  libxcursor,
  libxxf86vm,
  webkitgtk_6_0,
  version,
  src,
  vendorHash,
  componentName ? "client",
}:
let
  components = {
    client = {
      subPackage = "client";
      binaryName = "netbird";
      hasCompletion = true;
      hasVersionCheck = true;
    };
    ui = {
      subPackage = "client/ui";
      binaryName = "netbird-ui";
      hasCompletion = false;
      hasVersionCheck = false;
    };
  };
  component = components.${componentName};
in
buildGoModule {
  pname = "netbird-${componentName}";
  inherit version src vendorHash;

  nativeBuildInputs = [ installShellFiles ] ++ lib.optional (componentName == "ui") pkg-config;

  buildInputs = [
    gtk3
    libayatana-appindicator
    libx11
    libxcursor
    libxxf86vm
  ] ++ lib.optionals (componentName == "ui") [
    gtk4
    libsoup_3
    webkitgtk_6_0
  ];

  subPackages = [ component.subPackage ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/netbirdio/netbird/version.version=v${version}"
    "-X main.builtBy=nix"
  ];

  doCheck = false;

  preBuild = lib.optionalString (componentName == "ui") ''
    export PKG_CONFIG_PATH="${gtk4.dev}/lib/pkgconfig:${webkitgtk_6_0.dev}/lib/pkgconfig:${libsoup_3.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
  '';

  # work around Go 1.24+ strict embed check in wails dependency:
  # wails has //go:embed arm64/WebView2Loader.dll behind build constraint,
  # but Go >=1.24 checks ALL embed patterns during vendor regardless of build tags.
  modBuildPhase = ''
    runHook preBuild

    # download modules
    go mod download

    # create missing embed files in the wails module
    moduleDir=$(go env GOMODCACHE)/$(go list -m -f '{{.Path}}@{{.Version}}' github.com/wailsapp/wails/v3 2>/dev/null || echo "github.com/wailsapp/wails/v3@v3.0.0-alpha2.117")
    if [ -d "$moduleDir/internal/webview2/webviewloader" ]; then
      chmod -R u+w "$moduleDir"
      for arch in x86 x64 arm64; do
        mkdir -p "$moduleDir/internal/webview2/webviewloader/$arch"
        touch "$moduleDir/internal/webview2/webviewloader/$arch/WebView2Loader.dll"
      done
    fi

    # vendor modules
    go mod vendor

    runHook postBuild
  '';

  postPatch = ''
    substituteInPlace client/cmd/root.go \
      --replace-fail 'unix:///var/run/netbird.sock' 'unix:///var/run/netbird/sock'
  '' + lib.optionalString (componentName == "ui") ''
    substituteInPlace client/ui/grpc.go \
      --replace-fail 'unix:///var/run/netbird.sock' 'unix:///var/run/netbird/sock'

    # create placeholder frontend/dist for //go:embed all:frontend/dist
    mkdir -p client/ui/frontend/dist
    touch client/ui/frontend/dist/.gitkeep
  '';

  postInstall =
    ''
      mv $out/bin/${lib.last (lib.splitString "/" component.subPackage)} $out/bin/${component.binaryName}
    ''
    + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform && component.hasCompletion) ''
      installShellCompletion --cmd ${component.binaryName} \
        --bash <($out/bin/${component.binaryName} completion bash) \
        --fish <($out/bin/${component.binaryName} completion fish) \
        --zsh <($out/bin/${component.binaryName} completion zsh)
    ''
    + lib.optionalString (stdenv.hostPlatform.isLinux && componentName == "ui") ''
      install -Dm644 "$src/client/ui/assets/netbird-systemtray-connected.png" "$out/share/icons/hicolor/256x256/apps/netbird.png"
      install -Dm644 "$src/client/ui/build/linux/netbird.desktop" "$out/share/applications/netbird.desktop"
      substituteInPlace $out/share/applications/netbird.desktop \
        --replace-fail "/usr/bin/netbird-ui" "${component.binaryName}"
    '';

  nativeInstallCheckInputs = lib.optionals component.hasVersionCheck [
    versionCheckHook
  ];
  versionCheckProgram = "${placeholder "out"}/bin/${component.binaryName}";
  versionCheckProgramArg = "version";

  meta = {
    description = "Connect your devices into a single secure private WireGuard-based mesh network with SSO/MFA and simple access controls";
    homepage = "https://netbird.io";
    license = lib.licenses.bsd3;
    mainProgram = component.binaryName;
  };
}
