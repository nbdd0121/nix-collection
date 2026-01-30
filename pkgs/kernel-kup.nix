{
  lib,
  stdenv,
  fetchgit,
  perl,
  makePerlPath,
  ConfigSimple,
  Encode,
  PathTools,
  installShellFiles,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "kup";
  version = "0.3.6";

  src = fetchgit {
    url = "git://git.kernel.org/pub/scm/utils/kup/kup.git";
    rev = "kup-${version}";
    hash = "sha256-Q5kcni56M1Mp9f8IsQpCbD/16tC5MNQ8+R7NsMVBRcI=";
  };

  buildInputs = [
    perl
  ];

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  # We cannot use wrapProgram as -T flag makes PERL5LIB ineffective:
  # https://github.com/NixOS/nixpkgs/issues/263396
  postPatch = ''
    sed -i '/usr\/bin\/perl/a use lib "${makePerlPath [ ConfigSimple ]}"; use lib "${makePerlPath [ Encode ]}"; use lib "${makePerlPath [ PathTools ]}";' genrings gpg-sign-all kup kup-server
    substituteInPlace kup --replace-fail /bin:/usr/bin /usr/bin:/run/current-system/sw/bin
  '';

  installPhase = ''
    installBin genrings gpg-sign-all kup kup-server
    installManPage kup.1 kup-server.1
    mkdir $out/etc
    cp kup-server.cfg $out/etc
  '';
}
