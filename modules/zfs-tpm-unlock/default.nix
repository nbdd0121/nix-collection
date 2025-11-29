{
  config,
  pkgs,
  lib,
  utils,
  ...
}:
let
  cfg = config.boot.zfs.tpm-unlock;

  datasetToPool = x: builtins.elemAt (lib.splitString "/" x) 0;
  fsToPool = fs: datasetToPool fs.device;

  zfsFs = builtins.filter (x: x.fsType == "zfs") config.system.build.fileSystems;
  bootFs = builtins.filter utils.fsNeededForBoot zfsFs;
  bootPools = lib.unique (map fsToPool bootFs);

  systemd-script = pkgs.replaceVarsWith {
    isExecutable = true;
    src = ./zfs-load-key.sh;
    replacements = {
      zfs = config.boot.zfs.package;
      systemd = config.boot.initrd.systemd.package;
      pcr = lib.concatStringsSep "+" (map toString (builtins.sort builtins.lessThan cfg.pcr));
      inherit (pkgs) bash;
    };
  };
in
{
  options = {
    boot.zfs.tpm-unlock = {
      enable = lib.mkEnableOption "TPM unlock of ZFS filesystems";
      pcr = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [ 7 ];
        description = "PCRs to measure for decryption";
      };
      pools = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = bootPools;
        description = "Pools to unlock with TPM";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.boot.initrd.systemd.enable;
        message = "`boot.zfs.tpm-unlock` needs systemd stage 1";
      }
    ];

    # This module is taking over decryption
    boot.zfs.requestEncryptionCredentials = false;

    boot.initrd.systemd = {
      tpm2.enable = true;

      storePaths = [ systemd-script ];

      services = builtins.listToAttrs (
        map (
          pool:
          lib.nameValuePair "zfs-import-${pool}" {
            postStart = ''
              ${systemd-script} ${pool}
            '';
          }
        ) cfg.pools
      );
    };
  };
}
