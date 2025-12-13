{ pkgs }:
{
  inherit (pkgs.callPackage ./mongodb-bin.nix { }) mongodb-bin-7_0;
  herdtools7 = pkgs.ocamlPackages.callPackage ./herdtools7.nix { };
}
