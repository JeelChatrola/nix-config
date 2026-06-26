{ config, pkgs, lib, ... }:

let
  aiStackDir = config.home.homeDirectory + "/ai-stack";
  nixConfigDir = config.home.homeDirectory + "/nix-config";

  opencodeWrapper = pkgs.writeShellScriptBin "opencode" ''
    export OLLAMA_HOST="''${OLLAMA_HOST:-http://127.0.0.1:11434}"
    exec ${pkgs.nodejs_22}/bin/npx -y opencode-ai "$@"
  '';

  hermesWrapper = pkgs.writeShellScriptBin "hermes" ''
    export AI_STACK_DIR="${aiStackDir}"
    export NIX_CONFIG_DIR="${nixConfigDir}"
    exec "${aiStackDir}/bin/hermes" "$@"
  '';

  aiStackWrapper = pkgs.writeShellScriptBin "ai-stack" ''
    export AI_STACK_DIR="${aiStackDir}"
    exec "${aiStackDir}/bin/ai-stack" "$@"
  '';
in
{
  home.packages = [
    opencodeWrapper
    hermesWrapper
    aiStackWrapper
    pkgs.rtk
  ];

  home.sessionVariables = {
    AI_STACK_DIR = aiStackDir;
    NIX_CONFIG_DIR = nixConfigDir;
  };

  home.activation.rtkHermes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail
    mkdir -p "${config.home.homeDirectory}/.local/bin"
    ln -sfn "${pkgs.rtk}/bin/rtk" "${config.home.homeDirectory}/.local/bin/rtk"
    "${pkgs.rtk}/bin/rtk" init --agent hermes
  '';

  home.activation.aiStackSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail
    export AI_STACK_DIR="${aiStackDir}"
    export NIX_CONFIG_DIR="${nixConfigDir}"
    export PATH="${lib.makeBinPath [ pkgs.jq pkgs.yq-go pkgs.curl ]}:$PATH"
    if [[ ! -x "${aiStackDir}/bin/ai-stack" ]]; then
      echo "home-manager: clone private ai-stack to ${aiStackDir}" >&2
      echo "  git clone git@github.com:JeelChatrola/ai-stack.git ${aiStackDir}" >&2
      exit 1
    fi
    "${aiStackDir}/bin/ai-stack" sync
    "${aiStackDir}/bin/ai-stack" install
  '';
}
