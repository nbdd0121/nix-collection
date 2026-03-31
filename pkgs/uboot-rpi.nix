{
  lib,
  buildUBoot,
}:
buildUBoot {
  defconfig = "rpi_arm64_defconfig";
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [ "u-boot.bin" ];
}
