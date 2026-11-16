{
  imports = [
    ./ai.nix
    ./backup.nix
    ./dev.nix
    ./git.nix
    ./kitty.nix
    ./neovim
    ./nix.nix
    ./shell.nix
    ./ssh.nix
    ./tmux.nix
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
