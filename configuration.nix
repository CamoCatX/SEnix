{ config, pkgs, lib, ... }:
{
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
      ./sound.nix
      ./networking.nix
      ./locals.nix
      ./kernel.nix
      ./boot.nix
      ./sudo.nix
    ];
  environment.systemPackages = with pkgs; [
    wget
    ffmpeg
    sl
    nyancat
    git
    curl
    ranger
    htop
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
  hardware.enableAllFirmware  = true;
  programs.light.enable = true;
  nix.settings.allowed-users = mkDefault [ "jabbu" ];
  
  # Automatic upgrades
  system.autoUpgrade.enable = true;

  # Font config
  fonts.fonts = with pkgs; [
    hack-font
    source-code-pro
    meslo-lgs-nf
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Define a user account.
  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users.jabbu = {
      isNormalUser = true;
      home = "/home/jabbu";
      extraGroups = [ "networkmanager" "wheel" "video" "audio" "lp" "scanner" "podman" ];
      shell = pkgs.zsh;
    };
  };

  security.allowUserNamespaces = false;

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
  };
 
  #Copy system config, so I can make a backup 
  system.copySystemConfiguration = true;
  
  system.stateVersion = "23.05"; # Did you read the comment?
  
  #This is where the security stuff is.
  #SElinux is better then apparmour security wise, but apprmor is more engrained in the Nix ecosystem.
  security.apparmor.enable = true;
  security.apparmor.killUnconfinedConfinables = true;

  #No default packages
  environment.defaultPackages = lib.mkForce [];

  # Home-manager config
  home-manager.users.jabbu = { pkgs, config, ... }:
  {
    home.stateVersion = "23.05";
    home-manager.useGlobalPkgs = true;
    home.packages = [ ];
    programs.command-not-found.enable = true;

    #Kitty terminal
    programs.kitty = { 
      enable = true;
      font.package = pkgs.meslo-lgs-nf;
      font.name = "meslo-lgs-nf";
      theme = "Homebrew";
    };
  }
}
