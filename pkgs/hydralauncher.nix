{
  appimageTools,
  lib,
  version,
  src,
}:
let
  pname = "hydralauncher";
  appimageContents = appimageTools.extractType2 { inherit pname src version; };
in
appimageTools.wrapType2 {
  inherit pname src version;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/usr/share/icons/hicolor/512x512/apps/hydralauncher.png \
      $out/share/icons/hicolor/512x512/apps/hydralauncher.png

    install -Dm644 ${appimageContents}/hydralauncher.desktop \
      $out/share/applications/hydralauncher.desktop
    substituteInPlace $out/share/applications/hydralauncher.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${placeholder "out"}/bin/hydralauncher'
  '';

  meta = {
    description = "Game launcher with its own embedded bittorrent client";
    homepage = "https://github.com/hydralauncher/hydra";
    license = lib.licenses.mit;
    mainProgram = "hydralauncher";
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
