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
    helvum
    htop
    bsdgames
    home-manager
  ];
	    
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware  = true;
  programs.light.enable = true;
  
  # Automatic upgrades
  system.autoUpgrade.enable = true;

  # Font config
  fonts.fonts = with pkgs; [
    hack-font
    source-code-pro
    meslo-lgs-nf
  ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_CURRENT_DESKTOP = "sway"; 
  };
  
 # programs.sway.enable = true;     
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with Pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value, read the documentation for this option
  # (e.g., man configuration.nix or on https://nixos.org/nixos/options.html).
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
    
  # Coredump gives infomation (sometimes sensitive) during crash
  # and also slows down the system when something crashes
  systemd.coredump.enable = false; 

  # /tmp mounted on RAM, faster temp file management
  boot.tmp = {
    useTmpfs = lib.mkDefault true;
    cleanOnBoot = lib.mkDefault (!config.boot.tmp.useTmpfs);
  };

  # extra security
  boot.loader.systemd-boot.editor = false;

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

