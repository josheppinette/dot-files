{
  imports = [ ../../home.nix ];

  home.username = "josh";
  home.homeDirectory = "/home/josh";

  targets.genericLinux.enable = true;
}
