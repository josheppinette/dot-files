{
  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-system-graphics.url = "github:soupglasses/nix-system-graphics";
    nix-system-graphics.inputs.nixpkgs.follows = "nixpkgs";

    system-manager.url = "github:numtide/system-manager/release-26.05";
    system-manager.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";

    vim-rec.url = "github:zaid/vim-rec";
    vim-rec.flake = false;
  };

  outputs =
    {
      self,
      determinate,
      home-manager,
      llm-agents,
      nix-darwin,
      nix-system-graphics,
      nixpkgs,
      system-manager,
      vim-rec,
      ...
    }:
    let
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            (_: prev: {
              llm-agents = llm-agents.packages.${system};
              vimPlugins = prev.vimPlugins // {
                vim-rec = prev.vimUtils.buildVimPlugin {
                  pname = "vim-rec";
                  version = vim-rec.shortRev;
                  src = vim-rec;
                };
              };
            })
          ];
        };

      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      mkDarwin =
        system: module:
        nix-darwin.lib.darwinSystem {
          modules = [
            { nixpkgs.pkgs = mkPkgs system; }
            determinate.darwinModules.default
            home-manager.darwinModules.home-manager
            module
          ];
        };

      mkHome =
        system: module:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          modules = [ module ];
        };

      mkSystem =
        system: module:
        system-manager.lib.makeSystemConfig {
          modules = [
            { nixpkgs.hostPlatform = system; }
            nix-system-graphics.systemModules.default
            module
          ];
        };
    in
    {
      darwinConfigurations.mbp = mkDarwin "aarch64-darwin" ./hosts/mbp/darwin.nix;

      homeConfigurations."josh@t480" = mkHome "x86_64-linux" ./hosts/t480/home.nix;

      systemConfigs.t480 = mkSystem "x86_64-linux" ./hosts/t480/system.nix;

      # `nix flake check` skips `systemConfigs`.
      checks = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: config: config.system == system) self.systemConfigs
      );

      devShells = forAllSystems (system: {
        default =
          let
            pkgs = mkPkgs system;
          in
          pkgs.mkShell {
            packages = [
              pkgs.nixfmt
              pkgs.pre-commit
              pkgs.prettier
              pkgs.shfmt
              pkgs.stylua
            ];
          };
      });
    };
}
