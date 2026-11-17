{
  determinateNix.enable = true;

  determinateNix.customSettings.sandbox = "relaxed";

  programs._1password.enable = true;
  programs._1password-gui.enable = true;

  users.users.joshep.home = "/Users/joshep";

  system.stateVersion = 7;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.joshep = {
      imports = [ ../../modules/home ];

      programs.git.settings.user.email = "josh.eppinette@realtruck.com";
    };
  };
}
