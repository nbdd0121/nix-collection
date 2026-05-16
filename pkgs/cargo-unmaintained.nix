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
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-RZfPcaid7LTnzya6r4ScYfi5IYj9Mic0lclYe+sC+Bk=";
  };

  cargoHash = "sha256-VaBDt/RX6Znba2Z0hd7sGzNlLJH6JNt6oePw3mqu2Dg=";

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
