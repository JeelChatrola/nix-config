{ config, lib, pkgs, userProfile, ... }:

let
  aiStackDir = userProfile.aiStackDir;
  nixConfigDir = userProfile.nixConfigDir;

  opencodeWrapper = pkgs.writeShellScriptBin "opencode" ''
    export OLLAMA_HOST="''${OLLAMA_HOST:-http://127.0.0.1:11434}"
    exec ${pkgs.nodejs_22}/bin/npx -y opencode-ai@1.17.18 "$@"
  '';

  codexWrapper = pkgs.writeShellScriptBin "codex" ''
    export CODEX_HOME="''${CODEX_HOME:-$HOME/.codex}"
    exec ${pkgs.nodejs_22}/bin/npx -y @openai/codex@0.144.1 "$@"
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

  home.activation.removeLegacyAiEntrypoints = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    for name in ai-stack hermes deeptutor; do
      path="${config.home.homeDirectory}/.local/bin/$name"
      if [ -L "$path" ] && [ "$(${pkgs.coreutils}/bin/readlink "$path")" = "${aiStackDir}/bin/$name" ]; then
        $DRY_RUN_CMD rm "$path"
      fi
    done
  '';
}
