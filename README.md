<h1 align="center"> SEnix </h1> <div align="center"> <img src="./logo.png"><br>
  My personal NixOS configurations with a focus on security, privacy, and configurability.
</a><br> 
</div>
 
 # Some of my research:
 
  ### https://panopticlick.eff.org
  ### https://browserleaks.com/
  ### https://amiunique.org/
  ### https://www.deviceinfo.me/

nix-channel --add https://channels.nixos.org/nixos-unstable nixos

nixos-rebuild switch --upgrade

alias ols="ls -la --color | awk '{k=0;for(i=0;i<=8;i++)k+=((substr(\$1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(\" %0o \",k);print}'"

# Search through your command history and print the top 10 commands
alias history-stat='history 0 | awk ''{print $2}'' | sort | uniq -c | sort -n -r | head'
