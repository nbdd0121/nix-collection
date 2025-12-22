{
  lib,
  fetchgit,
  rustPlatform,
  python3,
}:
rustPlatform.buildRustPackage {
  pname = "coccinelle4rust";
  version = "0.1.0-unstable-20251205";

  src = fetchgit {
    url = "https://gitlab.inria.fr/coccinelle/coccinelleforrust.git";
    fetchSubmodules = false;
    rev = "6a9989cec0d18952b08a0b3db0ba72abe9727993";
    sha256 = "sha256-vHCAL4Ls3DHuOW8pju0SnnaSvMcQHDZSeXCFyQOHLoM=";
  };

  cargoHash = "sha256-8OkFn2uX3rNsZLoLc2PXyVYO/POzfQsn99YIwDMyUQo=";

  nativeBuildInputs = [ python3 ];

  doCheck = false;

  meta = with lib; {
    description = "Semantic patching tool for Rust";
    homepage = "https://gitlab.inria.fr/coccinelle/coccinelleforrust";
    license = with licenses; [ gpl2 ];
    mainProgram = "cfr";
  };
}
