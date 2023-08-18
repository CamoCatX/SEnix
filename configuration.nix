{ config, pkgs, lib, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in 
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };
  environment.systemPackages = with pkgs; [
    wget
    ffmpeg
    sl
    nyancat
    git
    curl
    ranger
    firefox-devedition
    htop
    unstable.distrobox
    vlc
    podman
    nano
    htop
    bsdgames
    home-manager
  ];
	    
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware  = true;
  programs.light.enable = true;
  nix.settings.allowed-users = mkDefault [ "@users" ];
  
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
    users.jabbu = {
      isNormalUser = true;
      home = "/home/jabbu";
      extraGroups = [ "networkmanager" "wheel" "video" "audio" "lp" "scanner" ];
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
    };
  };
 
  #Copy system config, so I can make a backup 
  system.copySystemConfiguration = true;
  
  system.stateVersion = "23.05"; # Did you read the comment?
  
  #This is where the security stuff is.
  #SElinux is better then apparmour security wise, but apprmor is more engrained in the Nix ecosystem.
  security.apparmor.enable = true;
  security.apparmor.killUnconfinedConfinables = true;
  #Firejail is a sandbox, so if something is compermised, then it can't spread.
  programs.firejail.enable = true;
  # Firefox
  programs.firejail.wrappedBinaries = {
    firefox = {
        executable = "${pkgs.lib.getBin pkgs.firefox}/bin/firefox";
        profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
      };
    };
 
  #No default packages
  environment.defaultPackages = lib.mkForce [];

  # Home-manager config
  home-manager.users.jabbu = { pkgs, ... }: {
    home.stateVersion = "23.05";
    home.packages = [ ];
    #Kitty terminal
     programs.kitty = { 
       enable = true;
       font.package = pkgs.meslo-lgs-nf;
       font.name = "meslo-lgs-nf";
       theme = "Homebrew";
     };
  };  
}

