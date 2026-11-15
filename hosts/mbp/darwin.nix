{
  determinateNix.enable = true;

  determinateNix.customSettings = {
    trusted-users = [
      "root"
      "@admin"
    ];
    sandbox = "relaxed";
  };

  users.users.jteppinette.home = "/Users/jteppinette";

  system.stateVersion = 7;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jteppinette = import ../../modules/home;
  };
}
