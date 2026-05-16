{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:
buildHomeAssistantComponent rec {
  owner = "hasscc";
  domain = "tianqi";
  version = "0.0.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "tianqi";
    rev = "e0424d1ca9f984dcbd30d491fb7d84e28331f14d";
    hash = "sha256-0HmcRkAnuLC76hjWOhiU9eR0d17O30ICFe1bzKMn6RI=";
  };

  dontBuild = true;

  meta = with lib; {
    homepage = "https://github.com/hasscc/tianqi";
  };
}
