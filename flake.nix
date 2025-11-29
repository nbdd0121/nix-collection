{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
    }:
    let
      noSystem = rec {
        nixosModules.default = import ./modules;
        nixosModule = nixosModules.default;
      };
      perSystem = flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          formatter = (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.wrapper;
        }
      );
    in
    noSystem // perSystem;
}
