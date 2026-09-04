{ config, lib, pkgs, ... }:

let
  opencodeWrapper = pkgs.writeShellScriptBin "opencode" ''
    export OLLAMA_HOST="''${OLLAMA_HOST:-http://127.0.0.1:11434}"
    exec ${pkgs.opencode}/bin/opencode "$@"
  '';

  codexWrapper = pkgs.writeShellScriptBin "codex" ''
    export CODEX_HOME="''${CODEX_HOME:-$HOME/.codex}"
    exec ${pkgs.codex}/bin/codex "$@"
  '';

  agentBrowserWrapper = pkgs.writeShellScriptBin "agent-browser" ''
    exec ${pkgs.agent-browser}/bin/agent-browser "$@"
  '';

  hermesWrapper = pkgs.writeShellScriptBin "hermes" ''
    export AI_STACK_DIR="''${AI_STACK_DIR:-$HOME/ai-stack}"
    exec "$AI_STACK_DIR/bin/hermes" "$@"
  '';

  deeptutorWrapper = pkgs.writeShellScriptBin "deeptutor" ''
    export AI_STACK_DIR="''${AI_STACK_DIR:-$HOME/ai-stack}"
    export DEEPTUTOR_HOME="''${DEEPTUTOR_HOME:-$HOME/deeptutor}"
    exec "$AI_STACK_DIR/bin/deeptutor" "$@"
  '';

  aiStackWrapper = pkgs.writeShellScriptBin "ai-stack" ''
    export AI_STACK_DIR="''${AI_STACK_DIR:-$HOME/ai-stack}"
    exec "$AI_STACK_DIR/bin/ai-stack" "$@"
  '';
in
{
  home.packages = [
    opencodeWrapper
    codexWrapper
    agentBrowserWrapper
    hermesWrapper
    deeptutorWrapper
    aiStackWrapper
  ];

  home.sessionVariables = {
    CODEX_HOME = config.home.homeDirectory + "/.codex";
    DEEPTUTOR_HOME = config.home.homeDirectory + "/deeptutor";
  };

  home.activation.removeLegacyAiEntrypoints = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    for name in ai-stack hermes deeptutor; do
      path="${config.home.homeDirectory}/.local/bin/$name"
      if [ -L "$path" ] && [ "$(${pkgs.coreutils}/bin/readlink "$path")" = "$HOME/ai-stack/bin/$name" ]; then
        $DRY_RUN_CMD rm "$path"
      fi
    done
  '';
}
