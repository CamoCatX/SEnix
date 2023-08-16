
# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "tattooine"; # Define your hostname.
  #How to connect to wifi nmcli dev wifi connect <mySSID> password <myPassword>
  #If already nmcli con up <mySSID>
  #Or just nmtui

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
 
  boot.kernelPackages = pkgs.linuxPackages_hardened;

  #No default packages
  environment.defaultPackages = lib.mkForce [];
    
  # Coredump gives infomation (sometimes sensitive) during crash
  # and also slows down the system when something crashes
  systemd.coredump.enable = false; 

  # Prevent replacing the running kernel w/o reboot
  security.protectKernelImage = true;
  #security.lockKernelModules = true;
  security.virtualisation.flushL1DataCache = "always";
  security.sudo.execWheelOnly = true;
  security.forcePageTableIsolation = true;

  # /tmp mounted on RAM, faster temp file management
  boot.tmp = {
    useTmpfs = lib.mkDefault true;
    cleanOnBoot = lib.mkDefault (!config.boot.tmp.useTmpfs);
  };

  # extra security
  boot.loader.systemd-boot.editor = false;

  boot.kernel.sysctl = {
    # The Magic SysRq key is a key combo that allows users connected to the
    # system console of a Linux kernel to perform some low-level commands.
    # Disable it, since we don't need it, and is a potential security concern.
    "kernel.sysrq" = 0;

    ## TCP hardening
    # Prevent bogus ICMP errors from filling up logs.
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    # Reverse path filtering causes the kernel to do source validation of
    # packets received from all interfaces. This can mitigate IP spoofing.
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    # Do not accept IP source route packets (we're not a router)
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    # Don't send ICMP redirects (again, we're on a router)
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    # Refuse ICMP redirects (MITM mitigations)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    # Protects against SYN flood attacks
    "net.ipv4.tcp_syncookies" = 1;
    # Incomplete protection again TIME-WAIT assassination
    "net.ipv4.tcp_rfc1337" = 1;

    ## TCP optimization
    # TCP Fast Open is a TCP extension that reduces network latency by packing
    # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
    # both incoming and outgoing connections:
    "net.ipv4.tcp_fastopen" = 3;
    # Bufferbloat mitigations + slight improvement in throughput & latency
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";
  };

  boot.kernelModules = ["tcp_bbr"];
 
  #Firewall 
  networking.firewall.enable = true;
  # Great resourse: https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
  #networking.firewall.allowedTCPPorts = [
  #  80 #http:// sites 
  #  443 #https:// sites 
  #  9418 #external git repos 
  #  #Do not worry about port 22 for ssh, it does that on auto
  #];
  #networking.firewall.allowedUDPPorts = [ 
  #  443
  #  80 
  #  44857
  #  53 
  #];
  networking.firewall.allowPing = false;
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

