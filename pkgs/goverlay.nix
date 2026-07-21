{
  autoPatchelfHook,
  coreutils,
  fontconfig,
  fpc,
  gnugrep,
  gnused,
  iproute2,
  kmod,
  lazarus-qt6,
  lib,
  libnotify,
  mangohud,
  p7zip,
  pascube,
  pciutils,
  polkit,
  qt6Packages,
  stdenv,
  version,
  src,
  wget,
}:
stdenv.mkDerivation {
  pname = "goverlay";
  inherit version src;

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    substituteInPlace data/goverlay.sh.in --replace-fail 'mangohud' "${lib.getExe' mangohud "mangohud"}"
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    fpc
    lazarus-qt6
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.libqtpas
    qt6Packages.qtbase
  ];

  buildPhase = ''
    runHook preBuild
    HOME=$(mktemp -d) lazbuild --lazarusdir=${lazarus-qt6}/share/lazarus -B goverlay.lpi --bm=Release
    HOME=$(mktemp -d) lazbuild --lazarusdir=${lazarus-qt6}/share/lazarus -B pascube_src/pascube.lpi
    cp pascube_src/pascube ./pascube
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make prefix=$out install
    runHook postInstall
  '';

  preFixup = ''
    qtWrapperArgs+=(--suffix PATH : ${
      lib.makeBinPath [
        coreutils
        fontconfig
        gnugrep
        gnused
        iproute2
        kmod
        libnotify
        mangohud
        p7zip
        pascube
        pciutils
        polkit
        wget
      ]
    })
  '';

  meta = {
    description = "Opensource project that aims to create a Graphical UI to help manage Linux overlays";
    homepage = "https://github.com/benjamimgois/goverlay";
    license = lib.licenses.gpl3Plus;
    mainProgram = "goverlay";
    platforms = lib.platforms.linux;
  };
}
