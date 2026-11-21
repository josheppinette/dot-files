{
  imports = [
    ./1password.nix
    ./ai.nix
    ./anki.nix
    ./backup.nix
    ./dev.nix
    ./firefox.nix
    ./git.nix
    ./kitty.nix
    ./neovim
    ./nix.nix
    ./obsidian.nix
    ./shell.nix
    ./ssh.nix
    ./tmux.nix
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
