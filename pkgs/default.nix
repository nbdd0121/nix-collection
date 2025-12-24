{ pkgs }:
{
  inherit (pkgs.callPackage ./mongodb-bin.nix { }) mongodb-bin-7_0;
  herdtools7 = pkgs.ocamlPackages.callPackage ./herdtools7.nix { };
  coccinelle4rust = pkgs.callPackage ./coccinelle4rust.nix { };
  patchwork = pkgs.python3Packages.callPackage ./patchwork.nix { };
  breaktimer = pkgs.callPackage ./breaktimer.nix {};
}
