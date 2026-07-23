{
  buildGoModule,
  fetchFromGitHub,
  lib,
  stdenv,
  versionCheckHook,
  installShellFiles,
  pkg-config,
  gtk3,
  libayatana-appindicator,
  libx11,
  libxcursor,
  libxxf86vm,
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

  nativeBuildInputs = [ installShellFiles ] ++ lib.optional (componentName == "ui") [ pkg-config ];

  buildInputs = [
    gtk3
    libayatana-appindicator
    libx11
    libxcursor
    libxxf86vm
  ];

  subPackages = [ component.subPackage ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/netbirdio/netbird/version.version=v${version}"
    "-X main.builtBy=nix"
  ];

  doCheck = false;

  postPatch = ''
    substituteInPlace client/cmd/root.go \
      --replace-fail 'unix:///var/run/netbird.sock' 'unix:///var/run/netbird/sock'
  '' + lib.optionalString (componentName == "ui") ''
    substituteInPlace client/ui/client_ui.go \
      --replace-fail 'unix:///var/run/netbird.sock' 'unix:///var/run/netbird/sock'
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
      install -Dm644 "$src/client/ui/build/netbird.desktop" "$out/share/applications/netbird.desktop"
      substituteInPlace $out/share/applications/netbird.desktop \
        --replace-fail "Exec=/usr/bin/netbird-ui" "Exec=${component.binaryName}"
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
