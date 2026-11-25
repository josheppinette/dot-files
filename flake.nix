{
  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    llm-agents.url = "github:numtide/llm-agents.nix";

    vim-rec.url = "github:zaid/vim-rec";
    vim-rec.flake = false;
  };

  outputs =
    inputs@{
      determinate,
      home-manager,
      llm-agents,
      nix-darwin,
      nixpkgs,
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
              ollama = if prev.stdenv.isDarwin then prev.callPackage ./pkgs/ollama.nix { } else prev.ollama;
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
            { home-manager.extraSpecialArgs = { inherit inputs; }; }
            module
          ];
        };

      mkNixos =
        system: module:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.pkgs = mkPkgs system; }
            determinate.nixosModules.default
            home-manager.nixosModules.home-manager
            { home-manager.extraSpecialArgs = { inherit inputs; }; }
            module
          ];
        };
    in
    {
      darwinConfigurations.MacBook-Pro = mkDarwin "aarch64-darwin" ./hosts/MacBook-Pro/darwin.nix;

      nixosConfigurations.homelab = mkNixos "x86_64-linux" ./hosts/homelab/nixos.nix;
      nixosConfigurations.t480 = mkNixos "x86_64-linux" ./hosts/t480/nixos.nix;

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
