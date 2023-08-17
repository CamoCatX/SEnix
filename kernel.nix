{ config, pkgs, lib, ... }:
{
   boot.kernelPackages = pkgs.linuxPackages_hardened;
   # Prevent replacing the running kernel w/o reboot
   security.protectKernelImage = true;
   #security.lockKernelModules = true;
   security.virtualisation.flushL1DataCache = "always";
   security.sudo.execWheelOnly = true;
   security.forcePageTableIsolation = true;
}
