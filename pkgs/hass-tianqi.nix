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
    rev = "bbc166f6b1caa25becb34b1764576616486290dd";
    hash = "sha256-RNJbvnsVpVj5AebehGo4jzUafnGx/mDAItghnbBH3zg=";
  };

  dontBuild = true;

  meta = with lib; {
    homepage = "https://github.com/hasscc/tianqi";
  };
}
