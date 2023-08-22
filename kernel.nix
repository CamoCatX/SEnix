{ config, pkgs, lib, ... }:
{
   boot.kernelPackages = pkgs.linuxPackages_latest_hardened;

   # Prevent replacing the running kernel w/o reboot
   security.protectKernelImage = true;
   #security.lockKernelModules = true;
   security.virtualisation.flushL1DataCache = "always";
   security.sudo.execWheelOnly = true;
   security.forcePageTableIsolation = true;
   boot.kernelParams = [
     # Slab/slub sanity checks, redzoning, and poisoning
     "slub_debug=FZP"

     # Overwrite free'd memory
     "page_poison=1"

     # Enable page allocator randomization
     "page_alloc.shuffle=1"
   ];
   boot.blacklistedKernelModules = [
     # Obscure network protocols
     "ax25"
     "netrom"
     "rose"
   ];
   boot.kernel.sysctl = { "kernel.dmesg_restrict" = 1; };
}
