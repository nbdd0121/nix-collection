{
  fetchFromGitHub,
  generateSplicesForMkScope,
  lib,
  newScope,
  pkgs,
  splicePackages,
  stdenv,
}:
let
  src = fetchFromGitHub {
    owner = "DeterminateSystems";
    repo = "nix-src";
    tag = "v3.20.0";
    hash = "sha256-oyHvP5HDRe59opmjTrq2ED9lh+R9FrHyaCGPPNfBqWM=";
  };

  nixDependencies =
    lib.makeScopeWithSplicing'
      {
        inherit splicePackages newScope;
      }
      {
        otherSplices = generateSplicesForMkScope "nixDependencies";
        f = import "${src}/packaging/dependencies.nix" {
          inputs = null;
          inherit stdenv pkgs;
        };
      };

  nixComponents =
    lib.makeScopeWithSplicing'
      {
        inherit splicePackages;
        inherit (nixDependencies) newScope;
      }
      {
        otherSplices = generateSplicesForMkScope "nixComponents";
        # I use det-nix for lazy trees and parallel eval only, which is not publicly visibile changes.
        # WASM builtin is, so disable it for now until it has been accepted upstream.
        extra = (_: { enableWasm = false; });
        f = import "${src}/packaging/components.nix" {
          inherit src lib pkgs;
          officialRelease = true;
          maintainers = [ ];
        };
      };
in
nixComponents.nix-everything
