{ pkgs }:
{
  inherit (pkgs.callPackage ./mongodb-bin.nix { }) mongodb-bin-7_0;
  herdtools7 = pkgs.ocamlPackages.callPackage ./herdtools7.nix { };
  coccinelle4rust = pkgs.callPackage ./coccinelle4rust.nix { };
  patchwork = pkgs.python3Packages.callPackage ./patchwork.nix { };
  breaktimer = pkgs.callPackage ./breaktimer.nix { };
  brow6el = pkgs.callPackage ./brow6el.nix { };
  kernel-kup = pkgs.perlPackages.callPackage ./kernel-kup.nix { };
  audio-share = pkgs.callPackage ./audio-share.nix { };
  uboot-rpi = pkgs.callPackage ./uboot-rpi.nix { };
  determinate-nix = pkgs.callPackage ./determinate-nix.nix { };
  chip-tool = pkgs.callPackage ./chip-tool.nix { };
  cargo-unmaintained = pkgs.callPackage ./cargo-unmaintained.nix { };
  hass-espsomfy-rts = pkgs.callPackage ./hass-espsomfy-rts.nix { };
  hass-tabbed-card = pkgs.callPackage ./hass-tabbed-card.nix { };
  ipt2socks = pkgs.callPackage ./ipt2socks.nix { };
}
