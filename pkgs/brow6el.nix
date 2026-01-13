{
  lib,
  stdenv,
  fetchgit,
  cmake,
  cef-binary,
  pkg-config,
  libsixel,
  xorg,
  libGL,
}:
stdenv.mkDerivation rec {
  pname = "brow6el";
  version = "0.3.3";

  src = fetchgit {
    url = "https://codeberg.org/janantos/brow6el.git";
    rev = "refs/tags/v${version}";
    hash = "sha256-/Fw7CxEgs+iQpyoC7vY82kIKXZ0wUXq09Da0a/U4SEA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libsixel
    xorg.libX11
  ];

  # Make sure the RPATH points to the installed location.
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail 'set(CMAKE_BUILD_RPATH ".")' 'set(CMAKE_BUILD_RPATH "'$out'/libexec/brow6el")'
  '';

  # Ensure libcef_dll_wrapper is built
  preConfigure = ''
    mkdir -p cef_binary/build
    ln -s ${cef-binary}/* cef_binary/
    cd cef_binary/build
    cmake -DCMAKE_BUILD_TYPE=Release ..
    make -j$NIX_BUILD_CORES libcef_dll_wrapper
    cd ../..
  '';

  installPhase = ''
    mkdir -p $out/{libexec,bin}
    cp -rf . $out/libexec/brow6el
    rm -rf $out/libexec/{CMake*,cmake*,Makefile,run_brow6el.sh}

    # Move brow6el into place.
    mv $out/libexec/brow6el/brow6el $out/bin/
  '';

  # brow6el copies CEF binaries, which can't be patched to avoid deps being removed.
  dontPatchELF = true;
  preFixup = ''
    # For some reason the binary contains a reference to cef_binary/Release, strip it.
    patchelf --allowed-rpath-prefixes /nix --shrink-rpath $out/bin/brow6el
    # For some reason this rpath is missing
    patchelf --add-rpath ${lib.makeLibraryPath [ libGL ]} $out/libexec/brow6el/libGLESv2.so
  '';

  meta = {
    description = "Minimalistic graphical terminal web browser using sixels.";
    homepage = "https://codeberg.org/janantos/brow6el";
    license = with lib.licenses; [ mit ];
    mainProgram = "brow6el";
  };
}
