{ config, pkgs, lib, ... }:
{
  networking.networkmanager.enable = true;
  networking.hostName = "tattooine"; # Define your hostname.
  networking.networkmanager.enableStrongSwan = true;
  networking.networkmanager.wifi.scanRandMacAddress = true;
  networking.networkmanager.wifi.macAddress = "random";
  networking.networkmanager.ethernet.macAddress = "random";
  networking.tempAddresses = "enabled";
  #How to connect to wifi nmcli dev wifi connect <mySSID> password <myPassword>
  #If already nmcli con up <mySSID>
  #Or just nmtui

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";

  #Firewall 
  networking.firewall.enable = true;
  # Great resourse: https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
  networking.firewall.allowedTCPPorts = [
    80 #http:// sites 
  #  443 #https:// sites 
  #  9418 #external git repos 
  #  #Do not worry about port 22 for ssh, it does that on auto
  ];
  #networking.firewall.allowedUDPPorts = [ 
  #  443
  #  80 
  #  44857
  #  53 
  #];
  networking.firewall.allowPing = false;
}
