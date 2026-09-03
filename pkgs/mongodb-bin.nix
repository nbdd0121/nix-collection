{
  lib,
  stdenv,
  rpmextract,
  fetchurl,
  curl,
  autoPatchelfHook,
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
        pname = "mongodb";

        src = fetchurl {
          inherit url sha256;
        };

        nativeBuildInputs = [
          rpmextract
          autoPatchelfHook
        ];

        buildInputs = buildInputs ++ [
          curl
          stdenv.cc.cc.lib
        ];

        unpackPhase = ''
          runHook preUnpack
          rpmextract $src
          runHook postUnpack
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out
          cd ./usr
          cp -ar bin share $out

          runHook postInstall
        '';

        meta = with lib; {
          description = "Binary distribution of MongoDB Community Server";
          sourceProvenance = with sourceTypes; [ binaryNativeCode ];
          license = licenses.sspl;
          platforms = platforms.unix;
        };
      }
    );
in
{
  mongodb-bin-7_0 = generic {
    version = "7.0.40";
    url =
      {
        x86_64-linux = "https://repo.mongodb.org/yum/redhat/9/mongodb-org/7.0/x86_64/RPMS/mongodb-org-server-7.0.40-1.el9.x86_64.rpm";
        aarch64-linux = "https://repo.mongodb.org/yum/redhat/9/mongodb-org/7.0/aarch64/RPMS/mongodb-org-server-7.0.40-1.el9.aarch64.rpm";
      }
      .${system};
    sha256 =
      {
        x86_64-linux = "sha256-N1tqVSO4JIp8ebw2LsUtpEDToUq4RKJPaf2rM2gaDfQ=";
        aarch64-linux = "sha256-bskT/1JrfUA4dA+E/pXBsaCVBAqmiz9aQ+le5GEOLE8=";
      }
      .${system};
  };
}
