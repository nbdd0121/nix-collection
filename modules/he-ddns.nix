{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.he-ddns;
in
{
  options = {
    services.he-ddns = {
      enable = lib.mkEnableOption "dynamic DNS update for Hurricane Electrics DNS service";
      v4 = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Perform update of IPv4 address";
      };
      v6 = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Perform update of IPv6 address";
      };
      hostname = lib.mkOption {
        type = lib.types.str;
        description = "Domain name to update";

      };
      passwordFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to ";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.v4 || cfg.v6;
        message = "Either `service.he-ddns.v4` or `service.he-ddns.v6` should be enabled.";
      }
    ];

    systemd.services.he-ddns = {
      description = "Update HE Dynamic DNS record";
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];

      path = with pkgs; [ curl ];

      script =
        (lib.optionalString cfg.v4 ''
          curl --ipv4 "https://dyn.dns.he.net/nic/update" -d "hostname=${cfg.hostname}" -d "password=''$(cat ${cfg.passwordFile})"
        '')
        + (lib.optionalString cfg.v6 ''
          curl --ipv6 "https://dyn.dns.he.net/nic/update" -d "hostname=${cfg.hostname}" -d "password=''$(cat ${cfg.passwordFile})"
        '');

      serviceConfig = {
        Type = "oneshot";
      };
    };

    systemd.timers.he-ddns = {
      description = "Update HE Dynamic DNS record periodically";
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      wantedBy = [ "default.target" ];
      startLimitBurst = 1;

      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = "5min";
      };
    };
  };
}
