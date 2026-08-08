{
  lib,
  stdenv,
  fetchgit,
  cmake,
  cef-binary,
  pkg-config,
  libsixel,
  libx11,
  libGL,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "brow6el";
  version = "0.3.5";

  src = fetchgit {
    url = "https://tangled.org/janantos.tngl.sh/brow6el.git";
    rev = "refs/tags/v${version}";
    hash = "sha256-XBmRqQUILhpCz0oFL6y03lrlCRgTn0nL8K57QBHPvDo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libsixel
    libx11
    zlib
  ];

  # Make sure the RPATH points to the installed location.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
        --replace-fail 'set(CMAKE_BUILD_RPATH ".")' 'set(CMAKE_BUILD_RPATH "'$out'/libexec/brow6el")'
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
    rm libcef.so
    ln -s ${cef-binary}/Release/libcef.so .

    mkdir -p $out/{libexec,bin}
    cp -ra . $out/libexec/brow6el
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
    platforms = [ "x86_64-linux" ];
  };
}
