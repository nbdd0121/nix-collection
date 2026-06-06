{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
}:
buildHomeAssistantComponent rec {
  owner = "rstrouse";
  domain = "espsomfy_rts";
  version = "2.4.7";

  src = fetchFromGitHub {
    owner = "rstrouse";
    repo = "ESPSomfy-RTS-HA";
    rev = "v${version}";
    hash = "sha256-F0cWvkTHexCHR1Pcp8jlNJpBAdzfC5Yk/7H2i8wj/u0=";
  };

  postPatch = ''
    substituteInPlace custom_components/espsomfy_rts/manifest.json --replace-fail "==1.8.0" "~=1.8"
  '';

  dependencies = with home-assistant.python3Packages; [
    websocket-client
    aiofiles
  ];

  dontBuild = true;

  meta = with lib; {
    description = "Control your somfy shades in Home Assistant";
    homepage = "https://github.com/rstrouse/ESPSomfy-RTS-HA";
    license = licenses.unlicense;
  };
}
