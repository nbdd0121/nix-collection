{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "ipt2socks";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "zfl9";
    repo = "ipt2socks";
    rev = "v${version}";
    hash = "sha256-kDQeAaR2zbQtHcaQQ+Qj3eT/JPiIrft3gV69lomh9eg=";
  };

  makeFlags = [ "DESTDIR=$(out)/bin" ];

  meta = with lib; {
    description = "Useful tool to convert iptables/nftables to socks5 traffic";
    license = licenses.afl3;
    platforms = platforms.linux;
    mainProgram = "ipt2socks";
  };
}
