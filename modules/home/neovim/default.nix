{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    initLua = builtins.readFile ./init.lua;
    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      conform-nvim
      fidget-nvim
      gitsigns-nvim
      lualine-nvim
      mini-nvim
      nvim-lspconfig
      nvim-parinfer
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context
      nvim-web-devicons
      sort-nvim
      vim-rec
    ];
    extraPackages = [
      pkgs.cargo
      pkgs.yarn
    ];
    withNodeJs = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
