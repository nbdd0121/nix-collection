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
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-s8Dwqz4bARod+XLP+2+p7pnmLh7I1OepWbKzYfWEMRI=";
  };

  cargoHash = "sha256-QLQBj8N2xH/oF/UVjXDiffdHUgPoAuifqGRaYshuS0E=";

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
