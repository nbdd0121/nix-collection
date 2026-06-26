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
        # With -fuse-ld=lld, this would invoke unwrapped LLD.
        export PATH=${llvmPackages.bintools}/bin:$PATH
        exec ${lib.getExe clang} "$@"
    fi
  '';

  rust-bindgen-unwrapped =
    (pkgs.rust-bindgen-unwrapped.override {
      inherit clang;
    }).overrideAttrs
      (
        final: prev: rec {
          version = "0.71.1";
          src = pkgs.fetchCrate {
            pname = "bindgen-cli";
            inherit version;
            hash = "sha256-RL9P0dPYWLlEGgGWZuIvyULJfH+c/B+3sySVadJQS3w=";
          };
          cargoHash = "sha256-4EyDjHreFFFSGf7UoftCh6eI/8nfIP1ANlYWq0K8a3I=";
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
    (rust-bin.stable."1.85.1".default.override {
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
