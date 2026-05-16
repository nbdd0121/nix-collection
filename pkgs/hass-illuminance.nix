{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:
buildHomeAssistantComponent rec {
  owner = "pnbruckner";
  domain = "illuminance";
  version = "5.8.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "ha-${domain}";
    rev = version;
    hash = "sha256-DO2j0AruPe1icpKCdkuG16uUzIPhGfMMBG5hdISwEks=";
  };

  dontBuild = true;

  meta = with lib; {
    description = "Home Assistant Illuminance Sensor";
    homepage = "https://github.com/pnbruckner/ha-illuminance";
    license = licenses.unlicense;
  };
}
