{ config, pkgs, lib, ... }:

let
  aiStackDir = config.home.homeDirectory + "/ai-stack";
  nixConfigDir = config.home.homeDirectory + "/nix-config";

  opencodeWrapper = pkgs.writeShellScriptBin "opencode" ''
    export OLLAMA_HOST="''${OLLAMA_HOST:-http://127.0.0.1:11434}"
    exec ${pkgs.nodejs_22}/bin/npx -y opencode-ai "$@"
  '';

  codexWrapper = pkgs.writeShellScriptBin "codex" ''
    export CODEX_HOME="''${CODEX_HOME:-$HOME/.codex}"
    exec ${pkgs.nodejs_22}/bin/npx -y @openai/codex "$@"
  '';

  hermesWrapper = pkgs.writeShellScriptBin "hermes" ''
    export AI_STACK_DIR="${aiStackDir}"
    exec "${aiStackDir}/bin/hermes" "$@"
  '';

  deeptutorWrapper = pkgs.writeShellScriptBin "deeptutor" ''
    export AI_STACK_DIR="${aiStackDir}"
    export DEEPTUTOR_HOME="''${DEEPTUTOR_HOME:-$HOME/deeptutor}"
    exec "${aiStackDir}/bin/deeptutor" "$@"
  '';

  aiStackWrapper = pkgs.writeShellScriptBin "ai-stack" ''
    export AI_STACK_DIR="${aiStackDir}"
    exec "${aiStackDir}/bin/ai-stack" "$@"
  '';
in
{
  home.packages = [
    opencodeWrapper
    codexWrapper
    hermesWrapper
    deeptutorWrapper
    aiStackWrapper
    pkgs.rtk
  ];

  home.sessionVariables = {
    AI_STACK_DIR = aiStackDir;
    NIX_CONFIG_DIR = nixConfigDir;
    CODEX_HOME = config.home.homeDirectory + "/.codex";
    DEEPTUTOR_HOME = config.home.homeDirectory + "/deeptutor";
  };

  home.activation.rtkHermes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail
    mkdir -p "${config.home.homeDirectory}/.local/bin"
    ln -sfn "${pkgs.rtk}/bin/rtk" "${config.home.homeDirectory}/.local/bin/rtk"
    "${pkgs.rtk}/bin/rtk" init --agent hermes
  '';

  home.activation.aiStackAgents = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail
    mkdir -p "${config.home.homeDirectory}/.local/bin"
    # ~/.local/bin is first on PATH (zsh-aliases.sh) — beats stale nix-store hermes from old HM gens.
    ln -sfn "${aiStackDir}/bin/hermes" "${config.home.homeDirectory}/.local/bin/hermes"
    ln -sfn "${aiStackDir}/bin/deeptutor" "${config.home.homeDirectory}/.local/bin/deeptutor"
    ln -sfn "${aiStackDir}/bin/ai-stack" "${config.home.homeDirectory}/.local/bin/ai-stack"
  '';
}
