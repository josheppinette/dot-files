# The nixpkgs build lacks the MLX engine, which is much faster on Apple Silicon.
{ fetchzip, runCommand }:

let
  version = "0.40.16";
  release = fetchzip {
    url = "https://github.com/ollama/ollama/releases/download/v${version}/ollama-darwin.tgz";
    hash = "sha256-2NvQPh0B48dgDazKUgmb20YG8LmVuOoH0G6SzLIN3pY=";
    stripRoot = false;
  };
in
runCommand "ollama-${version}" { meta.mainProgram = "ollama"; } ''
  mkdir -p $out/bin
  ln -s ${release}/ollama $out/bin/ollama
''
