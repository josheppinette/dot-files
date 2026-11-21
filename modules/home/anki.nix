{ config, ... }:

{
  programs.anki = {
    enable = true;
    profiles."User 1" = {
      default = true;
      sync = {
        username = "josheppinette@gmail.com";
        # The README explains how to create this file.
        keyFile = "${config.xdg.configHome}/anki/sync-key";
      };
    };
  };
}
