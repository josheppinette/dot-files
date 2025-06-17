{
  user,
  home,
  inputs,
  ...
}:
{
  nix = {
    optimise.automatic = true;
    gc.automatic = true;

    linux-builder = {
      enable = true;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      ephemeral = true;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 50 * 1024;
            memorySize = 8 * 1024;
          };
          cores = 4;
        };
      };
    };

    settings = {
      sandbox = true;
      trusted-users = [ "@admin" ];
      experimental-features = "nix-command flakes";
    };
  };

  users.users.${user}.home = home;

  system.stateVersion = 6;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit user home; };
    users.${user} = import ./home.nix;
    sharedModules = [ inputs.mac-app-util.homeManagerModules.default ];
  };
}
