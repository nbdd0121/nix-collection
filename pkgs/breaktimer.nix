{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  esbuild,
  electron,
  makeDesktopItem,
  makeShellWrapper,
  copyDesktopItems,
}:
buildNpmPackage rec {
  pname = "breaktimer";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "tom-james-watson";
    repo = "breaktimer-app";
    rev = "v${version}";
    sha256 = "sha256-STDb6+brlVk/ZPUbw3cQOpe2r03WlFKEBgVLqJrsrHI=";
  };

  npmDepsHash = "sha256-UL8e0UKZKhHHC+JvRpmcdBvFHlCdn3YknceVJ+knMgg=";

  postPatch = ''
    for file in app/main/lib/{windows.ts,notifications.ts}; do
      substituteInPlace $file --replace-fail 'process.resourcesPath' "'$out/share/lib/breaktimer/resources'"
    done
  '';

  nativeBuildInputs = [
    makeShellWrapper
    copyDesktopItems
  ];

  ESBUILD_BINARY_PATH = "${lib.getExe (
    esbuild.override {
      buildGoModule =
        args:
        buildGoModule (
          args
          // rec {
            version = "0.25.1";
            src = fetchFromGitHub {
              owner = "evanw";
              repo = "esbuild";
              rev = "v${version}";
              hash = "sha256-vrhtdrvrcC3dQoJM6hWq6wrGJLSiVww/CNPlL1N5kQ8=";
            };
            vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
          }
        );
    }
  )}";
  ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

  dontNpmBuild = true;
  buildPhase = ''
    runHook preBuild

    npm run build
    node_modules/.bin/electron-builder build --linux dir \
      -c.electronDist=${electron}/libexec/electron \
      -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/lib/breaktimer/resources"
    cp -r release/*-unpacked/{locales,resources{,.pak}} "$out/share/lib/breaktimer"

    install -m 444 -D resources/icon.png $out/share/icons/hicolor/256x256/apps/breaktimer.png

    makeShellWrapper '${electron}/bin/electron' "$out/bin/breaktimer" \
      --add-flags "$out/share/lib/breaktimer/resources/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-wayland-ime=true}}" \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "breaktimer";
      exec = "breaktimer %U";
      icon = "breaktimer";
      desktopName = "BreakTimer";
      comment = "Manage periodic breaks. Avoid eye-strain and RSI.";
      terminal = false;
    })
  ];

  meta = with lib; {
    description = "BreakTimer App";
    homepage = "https://github.com/tom-james-watson/breaktimer-app";
    license = licenses.gpl3;
  };
}
