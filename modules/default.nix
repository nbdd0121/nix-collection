{ ... }:
{
  imports = [
    ./github-key-sync.nix
    ./he-ddns.nix
    ./lanzaboote-memtest86.nix
    ./zfs-tpm-unlock
    ./pki-selective-trust
    ./kernel-fix
    ./btrfs-auto-snapshot.nix
  ];
}
