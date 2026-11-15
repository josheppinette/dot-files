{
  imports = [ ../../modules/home ];

  home.username = "josh";
  home.homeDirectory = "/home/josh";

  targets.genericLinux.enable = true;
}
