{ config, pkgs, lib, osConfig, ... }:

{
  
  home-manager.useGlobalPkgs = true;

  home-manager.users.jabbu = { pkgs, ... }: {
    /* The home.stateVersion option does not have a default and must be set */
    home.stateVersion = "23.11";
    lib.mkDefault.home.homeDirectory = "/home/jabbu/";
    
    #Kitty terminal
    programs.kitty = {
      font.package = pkgs.meslo-lgs-nf;
      font.name = "meslo-lgs-nf"; 
      enable = true;
      theme = "Homebrew";
    };
  };
}
