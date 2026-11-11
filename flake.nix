{
  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: Remove nixpkgs-unstable and mac-app-util follow once
    # our nixpkgs has SBCL >= 2.6.6.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    mac-app-util.url = "github:hraban/mac-app-util/039f33deef21782d4db97087f426504951239887";
    mac-app-util.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-system-graphics.url = "github:soupglasses/nix-system-graphics/5a8d749e977090c7f8c5b920b13262174b2d7b55";
    nix-system-graphics.inputs.nixpkgs.follows = "nixpkgs";

    system-manager.url = "github:numtide/system-manager/c9e35e9b7d698533a32c7e34dfdb906e1e0b7d0a";
    system-manager.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    {
      determinate,
      home-manager,
      llm-agents,
      mac-app-util,
      nix-darwin,
      nix-system-graphics,
      nixpkgs,
      system-manager,
      ...
    }@inputs:
    let
      pkgs = import nixpkgs {
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            llm-agents = llm-agents.packages.${prev.stdenv.hostPlatform.system};
          })
        ];
        system = builtins.currentSystem;
      };
      user = "jteppinette";
      home =
        with pkgs.stdenv;
        if isLinux then
          /home/${user}
        else if isDarwin then
          /Users/${user}
        else
          throw "unsupported system: ${system}";
      host = builtins.getEnv "HOST";
    in
    {
      systemConfigs.default = system-manager.lib.makeSystemConfig {
        modules = [
          nix-system-graphics.systemModules.default
          {
            nixpkgs.hostPlatform = builtins.currentSystem;
            system-graphics.enable = true;
          }
        ];
      };

      darwinConfigurations.${host} = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs user home; };
        modules = [
          { nixpkgs.pkgs = pkgs; }
          determinate.darwinModules.default
          mac-app-util.darwinModules.default
          home-manager.darwinModules.home-manager
          ./darwin.nix
        ];
      };

      homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = {
          inherit user home;
        };
      };

      devShells.${builtins.currentSystem}.default = pkgs.mkShell {
        packages = [
          pkgs.nixfmt-rfc-style
          pkgs.pre-commit
          pkgs.shfmt
          pkgs.stylua
        ];
      };
    };
}
