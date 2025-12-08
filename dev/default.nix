{ pkgs }:
{
  linux = pkgs.callPackage ./linux.nix { };
}
