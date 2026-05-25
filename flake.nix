{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }@publicInputs:
    let
      evalFlake = import ./lib/evalFlake.nix;
      inputs =
        (evalFlake {
          src = ./private;
          inputOverride = {
            inherit nixpkgs flake-utils;
          };
        }).inputs
        // publicInputs;
      inherit (inputs) treefmt-nix rust-overlay;

      noSystem = rec {
        nixosModules.default = import ./modules;
        nixosModule = nixosModules.default;
      };
      perSystem = flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs {
            config.allowUnfree = true;
            inherit system;
            overlays = [
              rust-overlay.overlays.default
            ];
          };
        in
        {
          devShells = import ./dev { inherit pkgs; };
          packages = flake-utils.lib.filterPackages system (import ./pkgs { inherit pkgs; });
          formatter = (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.wrapper;
        }
      );
    in
    noSystem // perSystem;
}
