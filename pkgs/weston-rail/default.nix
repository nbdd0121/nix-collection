{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  meson,
  ninja,
  pkg-config,
  wayland-scanner,
  wayland,
  libGL,
  libxkbcommon,
  cairo,
  libxcb,
  libXcursor,
  udev,
  libdrm,
  mtdev,
  libjpeg,
  pam,
  dbus,
  libinput,
  libevdev,
  pango ? null,
  libunwind ? null,
  libwebp,
  xwayland,
  wayland-protocols,
  librsvg,
  freerdp,
  openssl,
}:

with lib;
stdenv.mkDerivation {
  pname = "weston";
  version = "9.0.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "weston-mirror";
    rev = "a0fa768a68409b7bdfdc042a3981f9c20cf58068"; # build_with_freerdp_v3.8.0 branch
    hash = "sha256-HJ/f+jYZjjVEwDzsgCf7vTBw//N34s3LkSQxRlqnCYE=";
  };

  patches = [
    # Apply bugfixes on the "working" branch.
    (fetchpatch2 {
      url = "https://github.com/microsoft/weston-mirror/commit/2318fecaeac1f1a2d5a7a042c34d931c71dae04c.patch";
      hash = "sha256-9/OZIcEs6uXOLiOiSYVxythrjvrDXtHuVZLD64Cieo4=";
    })

    ./freerdp3.patch
    ./icons.patch
    ./defaults.patch
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    wayland
    libGL
    libxkbcommon
    cairo
    libdrm
    libxcb
    libXcursor
    udev
    mtdev
    libjpeg
    pam
    dbus
    libinput
    libevdev
    pango
    libunwind
    freerdp
    libwebp
    wayland-protocols
    librsvg
    openssl
  ];

  mesonFlags = [
    # Microsoft options
    (lib.mesonOption "backend-default" "rdp")
    (lib.mesonBool "backend-drm" false)
    (lib.mesonBool "backend-drm-screencast-vaapi" false)
    (lib.mesonBool "backend-headless" false)
    (lib.mesonBool "backend-wayland" false)
    (lib.mesonBool "backend-x11" false)
    (lib.mesonBool "backend-fbdev" false)
    (lib.mesonBool "color-management-colord" false)
    (lib.mesonBool "screenshare" false)
    (lib.mesonBool "remoting" false)
    (lib.mesonBool "pipewire" false)
    (lib.mesonBool "shell-fullscreen" false)
    (lib.mesonBool "color-management-lcms" false)
    (lib.mesonBool "shell-ivi" false)
    (lib.mesonBool "shell-kiosk" false)
    (lib.mesonBool "demo-clients" false)
    (lib.mesonOption "simple-clients" "")
    (lib.mesonOption "tools" "")
    (lib.mesonBool "resize-pool" false)
    (lib.mesonBool "wcap-decode" false)
    (lib.mesonBool "test-junit-xml" false)

    # Enable Xwayland with custom path
    (lib.mesonBool "xwayland" true)
    (lib.mesonOption "xwayland-path" (lib.getExe xwayland))
  ];

  postPatch = ''
    substituteInPlace "rdprail-shell/app-list.c" --replace-fail "/usr/share/" "/run/current-system/sw/share/"
  '';

  meta = {
    description = "RDP-RAIL wayland compositor";
    homepage = "https://github.com/microsoft/wslg";
    license = licenses.mit; # Expat version
    platforms = platforms.linux;
    mainProgram = "weston";
  };
}
