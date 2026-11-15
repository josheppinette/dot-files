{ pkgs, ... }:

let
  python = pkgs.python3.withPackages (ps: [
    ps.python-lsp-server
    ps.python-lsp-ruff
    ps.pylsp-mypy
    ps.grip
  ]);
in
{
  home.packages = [
    # formatters
    pkgs.nixfmt

    # languages
    pkgs.nodejs
    pkgs.llvmPackages.libcxxClang
    (pkgs.runCommand "python-env" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      mkdir -p $out/bin
      for f in ${python}/bin/*; do
        makeWrapper "$f" "$out/bin/$(basename "$f")"
      done
    '')

    # lsp
    pkgs.clang-tools
    pkgs.gopls
    pkgs.haskell-language-server
    pkgs.lua-language-server
    pkgs.nixd
    pkgs.ocamlPackages.ocaml-lsp
    pkgs.rust-analyzer
    pkgs.taplo
    pkgs.typescript-language-server
    pkgs.phpactor

    # build
    pkgs.gnumake
    pkgs.pkg-config
  ];

  editorconfig.enable = true;
  editorconfig.settings = {
    "*" = {
      charset = "utf-8";
      end_of_line = "lf";
      trim_trailing_whitespace = true;
      insert_final_newline = true;
    };
    "*.{php}" = {
      indent_style = "space";
      indent_size = 4;
    };
    "*.{c,h,cpp,hpp,cxx,hxx,tex,java,cabal,phtml,nix,json,ts,tsx,js,jsx,md,toml,yaml,ml,mli,opam,scala,sbt,sc}" =
      {
        indent_style = "space";
        indent_size = 2;
      };
    "{dune,dune-project,dune-workspace}" = {
      indent_style = "space";
      indent_size = 1;
    };
    "*.{bean,beancount}" = {
      indent_style = "space";
      indent_size = 2;
    };
    "*.{hs,lhs}" = {
      indent_style = "space";
      indent_size = 2;
    };
    "*.rs" = {
      indent_style = "space";
      indent_size = 4;
    };
    "*.go" = {
      indent_style = "tab";
      indent_size = 4;
    };
    "go.{mod,work,work.sum,sum}" = {
      charset = "unset";
      end_of_line = "unset";
      insert_final_newline = "unset";
      trim_trailing_whitespace = "unset";
      indent_style = "unset";
      indent_size = "unset";
    };
  };
}
