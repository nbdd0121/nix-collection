{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "scheduler-card";
  version = "4.0.18";

  src = fetchurl {
    url = "https://github.com/nielsfaber/${pname}/releases/download/v${version}/${pname}.js";
    hash = "sha256-GOXogRvJb+XGpAcWY+sRsLu7BrlXi+pn1PivRvE/MDA=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp $src $out/${pname}.js

    runHook postInstall
  '';

  meta = with lib; {
    description = "HA Lovelace card for control of scheduler entities.";
    homepage = "https://github.com/nielsfaber/${pname}";
    license = licenses.mit;
  };
}
