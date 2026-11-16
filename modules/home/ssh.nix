{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "~/.ssh/config.local" ];
    settings."*" = {
      ServerAliveInterval = 60;
      ServerAliveCountMax = 30;
    };
  };
}
