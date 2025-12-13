{
  lib,
  fetchurl,
  buildDunePackage,
  menhir,
  menhirLib,
  zarith,
  python3,
}:

buildDunePackage rec {
  pname = "herdtools7";
  version = "7.58";

  src = fetchurl {
    url = "https://github.com/herd/herdtools7/archive/refs/tags/${version}.tar.gz";
    hash = "sha256-G3J5hFfmeN7Hgc6RTEvYTca648PARM9CV9CXS/fwZq0=";
  };

  nativeBuildInputs = [
    menhir
    python3
  ];

  propagatedBuildInputs = [
    menhirLib
    zarith
  ];

  env = {
    DUNE_CACHE = "disabled";
  };

  preBuild = ''
    ./version-gen.sh $out
  '';

  postInstall = ''
    mkdir -p $out/share/herdtools7
    cp -r herd/libdir $out/share/herdtools7/herd
    cp -r litmus/libdir $out/share/herdtools7/litmus
    cp -r jingle/libdir $out/share/herdtools7/jingle
  '';

  meta = with lib; {
    homepage = "https://github.com/herd/herdtools7";
    description = "The Herd toolsuite to deal with .cat memory models";
    license = licenses.cecill-b;
  };
}
