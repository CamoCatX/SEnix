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
  systemd = {
  user.services.polkit-authentication-agent-1 = {
    description = "polkit-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit}/libexec/polkit-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
        # Sandboxing features
        PrivateTmp=yes
        NoNewPrivileges=true
        ProtectSystem=strict
        ProtectKernelTunables=yes
        ProtectKernelModules=yes
        ProtectControlGroups=yes
        PrivateDevices=yes
      };
  };
   extraConfig = ''
     DefaultTimeoutStopSec=10s
   '';

}
