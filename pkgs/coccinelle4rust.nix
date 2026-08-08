{
  lib,
  fetchgit,
  rustPlatform,
  python3,
}:
rustPlatform.buildRustPackage {
  pname = "coccinelle4rust";
  version = "0.1.0-unstable-20260615";

  src = fetchgit {
    url = "https://gitlab.inria.fr/coccinelle/coccinelleforrust.git";
    fetchSubmodules = false;
    rev = "86de52a92354f2af5d2e3d204ccfbf97258c2b3b";
    sha256 = "sha256-LN421TtYvy2D5SClYUDM1DZNehBT9xeSYDEPFPDm34o=";
  };

  cargoHash = "sha256-fKbv1oau0UBGD1/n9TWCARhGKhvd3s2wliIS4fxZO6E=";

  nativeBuildInputs = [ python3 ];

  doCheck = false;

  meta = with lib; {
    description = "Semantic patching tool for Rust";
    homepage = "https://gitlab.inria.fr/coccinelle/coccinelleforrust";
    license = with licenses; [ gpl2 ];
    mainProgram = "cfr";
  };
}
