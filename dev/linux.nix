{
  pkgs,
  lib,
  writers,
  mkShell,
  linux,
  rust-bin,
  b4,
  ncurses,
  ...
}:
let
  llvmPackages = pkgs.llvmPackages_18;
  inherit (llvmPackages) clang;

  # The clang provided by Nixpkgs by default have wrappers so it can correctly
  # find and link libraries. This is needed for HOSTCC but is not needed as CC.
  # We wrap clang so if `--target` is specified, the unwrapped clang is invoked directly
  # which skip the flag adding.
  wrappedClang = writers.writeBashBin "clang" ''
    target_specified=
    for arg in "$@"; do
        case "$arg" in
            "--target"*)
                target_specified=1
                ;;
        esac
    done

    if [[ -n $target_specified ]]; then
        # If --target flag is specified, don't invoke with wrappers.
        exec ${lib.getExe clang.cc} "$@"
    else
        exec ${lib.getExe clang} "$@"
    fi
  '';

  rust-bindgen-unwrapped =
    (pkgs.rust-bindgen-unwrapped.override {
      inherit clang;
    }).overrideAttrs
      (
        final: prev: rec {
          version = "0.69.5";
          src = pkgs.fetchCrate {
            pname = "bindgen-cli";
            inherit version;
            hash = "sha256-5S2ErALaqdn3KWU5DKaeBhe0UQISy2ajkX6aPhgd3xc=";
          };
          cargoHash = "sha256-FjBLw1eXj640ft9lD062+ihKHtmEpl4cVs+idfpZqas=";
          cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
            inherit src;
            name = "${final.pname}-${final.version}";
            hash = "${final.cargoHash}";
          };
        }
      );
in
mkShell {
  inputsFrom = [ linux ];
  packages = [
    (rust-bin.stable."1.78.0".default.override {
      extensions = [
        "rust-src"
        "clippy"
        "rust-analyzer"
      ];
    })
    rust-bindgen-unwrapped
    wrappedClang
    llvmPackages.lld
    llvmPackages.libllvm
    b4
  ];
  buildInputs = [
    # For menuconfig
    ncurses
  ];
}
