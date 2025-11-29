{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.boot.lanzaboote.memtest86;
in
{
  options = {
    boot.lanzaboote.memtest86 = {
      enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = ''
          Make Memtest86+ available from the systemd-boot menu.

          Memtest86+ is a program for testing memory.
        '';
      };

      sortKey = lib.mkOption {
        default = "o_memtest86";
        type = lib.types.str;
        description = ''
          `systemd-boot` orders the menu entries by their sort keys,
          so if you want something to appear after all the NixOS entries,
          it should start with `o` or onwards.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Lanzaboote hooks into the external bootloader mechanism, which simply points `installBootLoader` to `installHook`.
    # We "hijack" the option to run additionally script so we can install memtest86 too.
    system.build.installBootLoader = lib.mkForce (
      pkgs.writeShellScript "bootinstall" ''
        ${config.boot.loader.external.installHook}

        ${lib.getExe' pkgs.coreutils "mkdir"} -p ${config.boot.loader.efi.efiSysMountPoint}/EFI/memtest86/
        ${lib.getExe' pkgs.coreutils "cp"} ${pkgs.memtest86plus.efi} ${config.boot.loader.efi.efiSysMountPoint}/EFI/memtest86/memtest.efi
        ${lib.getExe pkgs.sbctl} sign ${config.boot.loader.efi.efiSysMountPoint}/EFI/memtest86/memtest.efi

        ${lib.getExe' pkgs.coreutils "mkdir"} -p ${config.boot.loader.efi.efiSysMountPoint}/loader/entries/
        ${lib.getExe' pkgs.coreutils "cp"} ${pkgs.writeText "memtest86.conf" ''
          title    Memtest86+
          efi      /efi/memtest86/memtest.efi
          sort-key ${cfg.sortKey}
        ''} ${config.boot.loader.efi.efiSysMountPoint}/loader/entries/memtest86.conf
      ''
    );
  };
}
