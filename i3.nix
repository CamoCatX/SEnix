{ config, pkgs, lib, ... }:
{

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    autorun = true;
    layout = "us";
    desktopManager = {
      xterm.enable = false;
    };
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3;
      extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock #default i3 screen locker
        i3blocks #if you are planning on using i3blocks over i3status
        lxappearence
      ];
    };
   # Enable display manager (light dm)
    displayManager = {
      defaultSession = "none+i3"; 
      lightdm = { 
        enable = true;
      }; 
    };
 #  # #windowManager.i3.config = "/etc/nixos/i3/config";  # Path to your i3 configuration
  };

  programs.dconf.enable = true;
}
