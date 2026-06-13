{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.btrfs.autoSnapshot;
in
{
  options = {
    services.btrfs.autoSnapshot = {
      enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = ''
          Enable the BTRFS auto-snapshotting service.

          Subvolumes being snapshotted should be specified via `subvolumes` option.
        '';
      };

      subvolumes = lib.mkOption {
        default = [ ];
        type = lib.types.listOf lib.types.path;
        description = ''
          Mount path to BTRFS subvolumes to be snapshotted.
        '';
      };

      frequent = lib.mkOption {
        default = 4;
        type = lib.types.int;
        description = ''
          Number of frequent (15-minute) auto-snapshots that you wish to keep.
        '';
      };

      hourly = lib.mkOption {
        default = 24;
        type = lib.types.int;
        description = ''
          Number of hourly auto-snapshots that you wish to keep.
        '';
      };

      daily = lib.mkOption {
        default = 7;
        type = lib.types.int;
        description = ''
          Number of daily auto-snapshots that you wish to keep.
        '';
      };

      weekly = lib.mkOption {
        default = 4;
        type = lib.types.int;
        description = ''
          Number of weekly auto-snapshots that you wish to keep.
        '';
      };

      monthly = lib.mkOption {
        default = 12;
        type = lib.types.int;
        description = ''
          Number of monthly auto-snapshots that you wish to keep.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      mkService = label: keep: {
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.btrfs-auto-snapshot}/bin/btrfs-auto-snapshot -q -k ${toString keep} -l ${label} ${
            lib.concatMapStringsSep " " lib.escapeShellArg cfg.subvolumes
          }";
        };
      };
      timers = {
        frequent = {
          keep = cfg.frequent;
          onCalendar = "*:0/15";
        };
        hourly = {
          keep = cfg.hourly;
          onCalendar = "hourly";
        };
        daily = {
          keep = cfg.daily;
          onCalendar = "daily";
        };
        weekly = {
          keep = cfg.weekly;
          onCalendar = "weekly";
        };
        monthly = {
          keep = cfg.monthly;
          onCalendar = "monthly";
        };
      };
    in
    {
      systemd.services = lib.mapAttrs' (
        label: t: lib.nameValuePair "btrfs-auto-snapshot-${label}" (mkService label t.keep)
      ) timers;

      systemd.timers = lib.mapAttrs' (
        label: t:
        lib.nameValuePair "btrfs-auto-snapshot-${label}" {
          wantedBy = [ "timers.target" ];
          timerConfig.OnCalendar = t.onCalendar;
          timerConfig.Persistent = true;
        }
      ) timers;
    }
  );
}
