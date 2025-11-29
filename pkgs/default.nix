{ pkgs }:
{
  inherit (pkgs.callPackage ./mongodb-bin.nix { }) mongodb-bin-7_0;
}
