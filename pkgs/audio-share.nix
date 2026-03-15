{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  asio,
  protobuf,
  cxxopts,
  spdlog,
  pipewire,
}:
stdenv.mkDerivation rec {
  pname = "audio-share";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "mkckr0";
    repo = "audio-share";
    rev = "v${version}";
    sha256 = "sha256-EuANnVwxeEzLhp8j/okQ2f1FSt4U61UK9kersgETBpQ=";
  };
  sourceRoot = "source/server-core";

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    asio
    protobuf
    cxxopts
    spdlog
    pipewire
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'find_package(Protobuf CONFIG REQUIRED)' 'find_package(Protobuf REQUIRED)' \
      --replace-fail 'find_package(asio CONFIG REQUIRED)' "" \
      --replace-fail 'asio::asio' ""
  '';

  cmakeFlags = [
    "-DASIO_INCLUDE_DIR=${asio}/include"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 as-cmd $out/bin/audio-share
    runHook postInstall
  '';

  meta = {
    description = "Audio Share can share Windows/Linux computer's audio to Android phone over network, so your phone becomes the speaker of computer.";
    homepage = "https://github.com/mkckr0/audio-share";
    license = with lib.licenses; [ asl20 ];
    mainProgram = "audio-share";
  };
}
