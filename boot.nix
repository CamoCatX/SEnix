{ config, pkgs, lib, ... }:
{
  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  # Coredump gives infomation (sometimes sensitive) during crash
  # and also slows down the system when something crashes
  systemd.coredump.enable = false; 
  # /tmp mounted on RAM, faster temp file management
  boot.tmp = {
    useTmpfs = lib.mkDefault true;
    cleanOnBoot = lib.mkDefault (!config.boot.tmp.useTmpfs);
  };
  security.polkit.enable = true;
}
