{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  zlib,
}:
rustPlatform.buildRustPackage rec {
  pname = "cargo-unmaintained";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-W2hez2cw2WqokdnP2zUVUPuRDdms65wmxbEFj7bk2yQ=";
  };

  cargoHash = "sha256-7Ss4B1RBwcGjAsStWVD+HRxZQfrzlBqpaOl3NrGa1xY=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    zlib
  ];

  # Need rustup and others.
  doCheck = false;

  meta = with lib; {
    description = "Find unmaintained packages in Rust projects";
    license = with licenses; [ agpl3Only ];
  };
}
