# Base on https://github.com/Sped0n/chip-host-tools.nix/blob/main/packages/chip-host-tools/base.nix
# Modified to just support latest version.
{
  lib,
  stdenv,
  fetchgit,
  fetchFromGitHub,
  zap-chip,
  gn,
  ninja,
  pkg-config,
  python3,
  glib,
  ccache,
  ccacheWrapper,
  dbus,
  avahi,
  libevent,
  openssl,
  readline,
}:
let
  version = "1.5.1.0";

  src = fetchFromGitHub {
    owner = "project-chip";
    repo = "connectedhomeip";
    rev = "v1.5.1.0";
    hash = "sha256-U1LcoeZGY2RmSgH3CVMAO9UxFZPcpgWDbtRNdH1WDR0=";
  };

  openthreadSrc = fetchFromGitHub {
    owner = "openthread";
    repo = "openthread";
    rev = "687cc3664875e1ef2e30c1df4cfc9c14754782a5";
    hash = "sha256-5lPSjoP0u0A6R619jwAQrbKCYUH+B0RclnbL8yQThho=";
  };

  fetchedSubmoduleSources = [
    {
      path = "third_party/nlassert/repo";
      url = "https://github.com/nestlabs/nlassert.git";
      rev = "c5892c5ae43830f939ed660ff8ac5f1b91d336d3";
      hash = "sha256-CT15ld/VuyBHz3du+npBnmBDHuFM11fFjusDgvTAS3k=";
    }
    {
      path = "third_party/nlio/repo";
      url = "https://github.com/nestlabs/nlio.git";
      rev = "0e725502c2b17bb0a0c22ddd4bcaee9090c8fb5c";
      hash = "sha256-LGvIhFB5iLYPDrj4J2hYBZ7Erxxq7mi7dg/8VrKDo1E=";
    }
    {
      path = "third_party/pigweed/repo";
      url = "https://github.com/google/pigweed.git";
      rev = "abf16415ace60cd29691fc55c14a654975800c88";
      hash = "sha256-AcKQqYefjat3BjoK+AMf7LaMLiZnBPiSKbuRswbhWk0=";
    }
    {
      path = "third_party/perfetto/repo";
      url = "https://github.com/google/perfetto.git";
      rev = "b9aca8fb0a7d4130e6ad0b33ca3d14abbc276185";
      hash = "sha256-RcW7m0ejdJt4D77d0bvNsbwb1kU3fvF9fx7wVKyelFA=";
    }
    {
      path = "third_party/lwip/repo";
      url = "https://github.com/lwip-tcpip/lwip.git";
      rev = "4599f551dead9eac233b91c0b9ee5879f5d0620a";
      hash = "sha256-mg+zatxp3F1lEpuZt//63NGcyjbxi5/Xs6gR5KAU2Fw=";
    }
    {
      path = "third_party/libwebsockets/repo";
      url = "https://github.com/warmcat/libwebsockets";
      rev = "edc6a44ea2f779a7291b8b155a2152cfd05ba863";
      hash = "sha256-fFaM5J/PDiqtJ1Q9s+ZzIw9XY4x1psgjQYs4QMa6DcE=";
    }
    {
      path = "third_party/editline/repo";
      url = "https://github.com/troglobit/editline.git";
      rev = "f735e4d1d566cac3caa4a5e248179d07f0babefd";
      hash = "sha256-MUXxSmhpQd8CZdGGC6Ln9eci85E+GBhlNk28VHUvjaU=";
    }
    {
      path = "third_party/nanopb/repo";
      url = "https://github.com/nanopb/nanopb.git";
      rev = "671672b4d7994a9b07a307ae654885c7202ae886";
      hash = "sha256-o0xbxAFj86EvnldHk7ao8ltBBzxm4TgkChvNVME6n78=";
    }
    {
      path = "third_party/jsoncpp/repo";
      url = "https://github.com/open-source-parsers/jsoncpp.git";
      rev = "ca98c98457b1163cca1f7d8db62827c115fec6d1";
      hash = "sha256-RX9ZV6zEn3RDN/n6FE4iJJ+MR1LB5vKbsQ/XmpqYbB0=";
    }
  ];

  skippedSubmodulePaths = [ ];

  pythonEnv = python3.withPackages (
    ps: with ps; [
      click
      coloredlogs
      jinja2
      lark
      lxml
      ps."python-path"
    ]
  );

  ccCompiler = "${ccacheWrapper}/bin/cc";
  cxxCompiler = "${ccacheWrapper}/bin/c++";
  gnTargetCpu =
    {
      aarch64 = "arm64";
      x86_64 = "x64";
      i686 = "x86";
      armv7l = "arm";
    }
    .${stdenv.hostPlatform.parsed.cpu.name}
      or (throw "Unsupported GN target_cpu for ${stdenv.hostPlatform.system}");

  gnArgs = [
    "chip_build_tools=true"
    ''chip_mdns="platform"''
    ''chip_crypto="openssl"''
    "chip_inet_config_enable_ipv4=false"
    "symbol_level=0"
    "is_debug=false"
    ''custom_toolchain="//build/toolchain/custom"''
    ''target_cc="${ccCompiler}"''
    ''target_cxx="${cxxCompiler}"''
    ''target_ar="${stdenv.cc.bintools}/bin/ar"''
    ''target_cpu="${gnTargetCpu}"''
  ]
  ++ lib.optionals stdenv.isDarwin [ ''mac_deployment_target="darwin"'' ];

  submoduleSources =
    map (
      { path, ... }@source:
      {
        inherit path;
        src = fetchgit (removeAttrs source [ "path" ]);
      }
    ) fetchedSubmoduleSources
    ++ [
      {
        path = "third_party/openthread/repo";
        src = openthreadSrc;
      }
    ];

  linkedSubmoduleSources = builtins.filter (
    source: !(builtins.elem source.path skippedSubmodulePaths)
  ) submoduleSources;

  linkSubmodules = lib.concatMapStringsSep "\n" (
    { path, src }:
    ''
      rmdir "${path}"
      mkdir -p "$(dirname "${path}")"
      ln -s ${src} "${path}"
    ''
  ) submoduleSources;
in
stdenv.mkDerivation {
  pname = "chip-host-tool";

  inherit version src;

  strictDeps = true;
  enableParallelBuilding = true;
  hardeningDisable = lib.optionals stdenv.isDarwin [ "stackclashprotection" ];

  nativeBuildInputs = [
    ccache
    gn
    ninja
    pkg-config
    zap-chip
    pythonEnv
    glib
  ];

  buildInputs = [
    glib
    libevent
    openssl
    readline
  ]
  ++ lib.optionals stdenv.isLinux [
    avahi
    dbus
  ];

  doInstallCheck = true;

  postPatch = ''
    ${linkSubmodules}

    ${lib.optionalString stdenv.isDarwin ''
      python -c '
      from pathlib import Path

      path = Path("examples/chip-tool/BUILD.gn")
      old = """if (chip_device_platform == \"darwin\" || chip_crypto == \"boringssl\") {"""
      new = """if (chip_crypto == \"boringssl\") {"""
      content = path.read_text()
      if old not in content:
          raise SystemExit("failed to locate chip-tool boringssl dependency condition")
      path.write_text(content.replace(old, new, 1))
      '
    ''}

    cat > build_overrides/pigweed_environment.gni <<'EOF'
    # Generated for Nix builds.
    # The full Pigweed bootstrap flow downloads external tools and is intentionally skipped here.
    EOF
  '';

  configurePhase = ''
    runHook preConfigure

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"

    export CC="${ccCompiler}"
    export CXX="${cxxCompiler}"

    build_dir="$PWD/out/host"
    mkdir -p "$build_dir"

    gn gen \
      --check \
      --fail-on-unused-args \
      --script-executable="${pythonEnv}/bin/python" \
      "$build_dir" \
      --args='${lib.concatStringsSep " " gnArgs}'

    runHook postConfigure
  '';

  buildPhase = ''
    ninjaFlagsArray+=(
      -C "$PWD/out/host"
      chip-tool
      chip-cert
    )
    ninjaBuildPhase
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 out/host/chip-tool "$out/bin/chip-tool"
    install -Dm755 out/host/chip-cert "$out/bin/chip-cert"

    runHook postInstall
  '';

  installCheckPhase = ''
    runHook preInstallCheck

    set -o pipefail

    payload_parse_output="$TMPDIR/chip-tool-payload-parse.txt"
    "$out/bin/chip-tool" payload parse-setup-payload 34970112332 2>&1 | tee "$payload_parse_output"
    grep -q "Passcode:.*20202021" "$payload_parse_output"

    "$out/bin/chip-cert" help

    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "Matter host tools from Project CHIP";
    homepage = "https://github.com/project-chip/connectedhomeip";
    license = licenses.asl20;
    mainProgram = "chip-tool";
    platforms = platforms.unix;
  };
}
