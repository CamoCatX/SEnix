{ pkgs, lib, config, ... }:

{
  home-manager.users.jabbu = { pkgs, ... }:
  {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      meslo-lgs-nf
    ];

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autocd = true;
      sessionVariables = {
        TERM="xterm-256color";
      };

      zplug = {
        enable = true;
        plugins = [{
          name = "romkatv/powerlevel10k";
          tags = [ "as:theme" "depth:1" ];
        }];
      };

      history = {
        save = 100;
        size = 100;  
        path = "$HOME/.cache/zsh_history";
        ignoreAllDups = true;
      };

      plugins = [
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
          {
            name = "powerlevel10k-config";
            src = ./p10k-config;
            file = "p10k.zsh";
        }
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.7.0";
            sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";
          };
        }
      ];
    };
  };
}
