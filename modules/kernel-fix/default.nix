{
  config,
  lib,
  ...
}:
{
  # Apply important bugfixes that are not yet upstream.
  config = {
    boot.kernelPatches =
      lib.mkIf
        (
          # Bug is backported to 6.12.67 and newer
          (lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.12.67")
          # Rebuilding kernel is expensive so only do it when tunnel is used.
          && (lib.any (x: x.tunnelConfig != { }) (lib.attrValues config.systemd.network.netdevs))
        )
        [
          {
            name = "revert_ip6_tunnel_use_skb_vlan_inet_prepare";
            patch = ./revert_ip6_tunnel_use_skb_vlan_inet_prepare.patch;
          }
        ];
  };
}
