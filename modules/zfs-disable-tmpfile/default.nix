{
  config,
  lib,
  pkgs,
  ...
}:

let

  bpf = pkgs.callPackage (
    {
      stdenv,
      lib,
      libbpf,
      bpftools,
      clang,
      linuxHeaders,
    }:

    stdenv.mkDerivation {
      pname = "zfs-disable-tmpfile";
      version = "0.1.0";

      src = ./.;

      nativeBuildInputs = [
        clang
      ];

      buildInputs = [
        libbpf
        linuxHeaders
      ];

      buildPhase = ''
        clang -O2 -g -target bpf -c zfs_disable_tmpfile.bpf.c -o zfs_disable_tmpfile.bpf.o
      '';

      hardeningDisable = [
        "stackprotector"
        "zerocallusedregs"
      ];

      installPhase = ''
        mkdir -p $out
        cp zfs_disable_tmpfile.bpf.o $out
      '';

      meta = with lib; {
        description = "BPF LSM program to disable tmpfile support for ZFS";
        license = licenses.gpl2Only;
        platforms = platforms.linux;
      };
    }
  ) { };
in
{
  options.boot.zfs.disableTmpfile = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = "Whether to disable tmpfile support for ZFS";
  };

  config = lib.mkIf config.boot.zfs.disableTmpfile {
    systemd.services.zfs-disable-tmpfile = {
      description = "Disable tmpfile support for ZFS";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${lib.getExe' pkgs.bpftools "bpftool"} prog loadall ${bpf}/zfs_disable_tmpfile.bpf.o /sys/fs/bpf/zfs_disable_tmpfile autoattach";
        ExecStop = "${lib.getExe' pkgs.coreutils "rm"} -r /sys/fs/bpf/zfs_disable_tmpfile";
      };
    };
  };
}
