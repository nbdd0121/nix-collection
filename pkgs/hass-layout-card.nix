{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "layout-card";
  version = "2.4.7";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-layout-card";
    rev = "v${version}";
    hash = "sha256-xni9cTgv5rdpr+Oo4Zh/d/2ERMiqDiTFGAiXEnigqjc=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp $src/layout-card.js $out/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Get more control over the placement of lovelace cards.";
    homepage = "https://github.com/thomasloven/lovelace-layout-card";
    license = licenses.mit;
  };
}
