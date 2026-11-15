{ pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "~/.ssh/config.local" ];
    settings."*" = {
      ServerAliveInterval = 60;
      ServerAliveCountMax = 30;
      IdentityAgent =
        if pkgs.stdenv.isDarwin then
          ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"''
        else
          "~/.1password/agent.sock";
    };
  };
}
