{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "tabbed-card";
  version = "0.3.3";

  src = fetchurl {
    url = "https://github.com/kinghat/${pname}/releases/download/v${version}/tabbed-card.js";
    hash = "sha256-bq1fmXdAtrTxYtJoMqSypvvLwFB7jpRw8PaiUa6OkBo=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp $src $out/tabbed-card.js

    runHook postInstall
  '';

  meta = with lib; {
    description = "A custom card for home assistant that utilizes tabs to segregate individual cards.";
    homepage = "https://github.com/kinghat/tabbed-card";
    license = licenses.mit;
  };
}
