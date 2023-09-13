{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
    ./sound.nix
    ./networking.nix
    ./locals.nix
    ./kernel.nix
    ./boot.nix
    #./kde.nix
    #./firefox.nix
    ./zsh.nix
    ./sway.nix
  ];

  environment.systemPackages = with pkgs; [
    wget
    ffmpeg
    sl
    nyancat
    git
    curl
    ranger
    glances
    distrobox
    vlc
    nano
    bsdgames
    chkrootkit
    lynis
    pciutils
    cmatrix
    nurl
  ];
	    
  nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = [
      "python2"
    ];

  programs.light.enable = true;
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = lib.optionalString (config.nix.package == pkgs.nixFlakes)
      "experimental-features = nix-command flakes";
    settings = {
      allowed-users = [ "jabbu" ];
      auto-optimise-store = true;
    };
  };
  programs.dconf.enable = true;
  hardware.rtl-sdr.enable = true;
  powerManagement.enable = true;
  time.hardwareClockInLocalTime = true;
  
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
      };
  };
   extraConfig = ''
     DefaultTimeoutStopSec=10s
   '';
}; 
  # Font config
  fonts = {
    packages = with pkgs; [
      hack-font
      anonymousPro
      meslo-lgs-nf
    ];
  fontDir.enable = true;
      fontconfig = {
        enable = true;
        cache32Bit = true;
     };
   };
  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Define a user account.
  users = {
    defaultUserShell = pkgs.zsh;
    users.jabbu = {
      isNormalUser = true;
      home = "/home/jabbu";
      extraGroups = [ "networkmanager" "wheel" "video" "audio" "lp" "scanner" "podman" "plugdev" "libvirtd" ];
      shell = pkgs.zsh;
    };
  };
  programs.zsh.enable = true;

 # Podman
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
      dockerSocket.enable = true;
    };
    vmware.host.enable = true;
  };
 
   #Copy system config, so I can make a backup 
   system.copySystemConfiguration = true;
  
   system.stateVersion = "23.11";
  
   home-manager.useGlobalPkgs = true;

   home-manager.users.jabbu = { pkgs, ... }: {
     /* The home.stateVersion option does not have a default and must be set */
     home.stateVersion = "23.11";
     lib.mkDefault.home.homeDirectory = "/home/jabbu/"; 
      #Kitty terminal
      programs.kitty = {
        font.name = "meslo-lgs-nf"; 
        enable = true;
        theme = "Homebrew";
        shellIntegration.mode = "no-title";
        shellIntegration.enableZshIntegration = true;
      };
    };

  #No default packages
  environment.defaultPackages = lib.mkForce [];

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };
}
