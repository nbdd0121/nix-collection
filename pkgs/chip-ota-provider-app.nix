{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libnl,
}:
let
  inherit (stdenv) system;
  generic =
    {
      version,
      url,
      sha256,
      buildInputs ? [ ],
      ...
    }@args:
    stdenv.mkDerivation (
      args
      // {
        pname = "chip-ota-provider-app";

        src = fetchurl {
          inherit url sha256;
        };

        nativeBuildInputs = [
          autoPatchelfHook
        ];

        buildInputs = buildInputs ++ [
          libnl
          stdenv.cc.cc.lib
        ];

        dontUnpack = true;

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin
          install -Dm755 $src $out/bin/chip-ota-provider-app

          runHook postInstall
        '';

        meta = with lib; {
          description = "Matter OTA Provider";
          sourceProvenance = with sourceTypes; [ binaryNativeCode ];
          license = licenses.asl20;
          platforms = platforms.unix;
        };
      }
    );
in
generic {
  version = "2025.9.0";
  url =
    {
      x86_64-linux = "https://github.com/home-assistant-libs/matter-linux-ota-provider/releases/download/2025.9.0/chip-ota-provider-app-x86-64";
      aarch64-linux = "https://github.com/home-assistant-libs/matter-linux-ota-provider/releases/download/2025.9.0/chip-ota-provider-app-aarch64";
    }
    .${system};
  sha256 =
    {
      x86_64-linux = "sha256-RVDfevZSnkYgRj0cASf4MOwkBMgXrUxjQ7KeMs7AFE4=";
      aarch64-linux = "sha256-4GirbEBQ4j6qbM2pv37M3Et5KiUU4QmMvBK0FM1kqn4=";
    }
    .${system};
}
