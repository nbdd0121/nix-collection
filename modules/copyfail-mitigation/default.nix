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
      pname = "copyfail-mitigation";
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
        clang -O2 -target bpf -c copyfail_mitigation.bpf.c -o copyfail_mitigation.bpf.o
      '';

      hardeningDisable = [
        "stackprotector"
        "zerocallusedregs"
      ];

      installPhase = ''
        mkdir -p $out
        cp copyfail_mitigation.bpf.o $out
      '';

      meta = with lib; {
        description = "BPF LSM program to mitigate copyfail";
        license = licenses.gpl2Only;
        platforms = platforms.linux;
      };
    }
  ) { };
in
{
  options.security.copyfail-mitigation = {
    enable = lib.mkEnableOption "BPF LSM filter to mitigate copyfail";
  };

  config = lib.mkIf config.security.copyfail-mitigation.enable {
    systemd.services.copyfail-mitigation = {
      description = "Mitigate copyfail";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${lib.getExe' pkgs.bpftools "bpftool"} prog load ${bpf}/copyfail_mitigation.bpf.o /sys/fs/bpf/copyfail_mitigation autoattach";
        ExecStop = "${lib.getExe' pkgs.coreutils "rm"} /sys/fs/bpf/copyfail_mitigation";
      };
    };
  };
}
