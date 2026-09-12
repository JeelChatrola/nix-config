# Mise (per-project runtimes).
#
# The locked Home Manager input predates `programs.mise`, so this wires the
# Nix-provided binary plus Zsh activation directly instead of using that
# module. Nix still supplies the system Node 24 / uv / Python toolchain used
# by ai-stack. Mise manages per-project runtimes (project-local `.mise.toml` /
# `.tool-versions`) without competing with those system tools: no global tool
# pins here, so `mise` never shadows the Nix-provided defaults unless a
# project directory explicitly requests it.

{ lib, pkgs, ... }:

{
  home.packages = [ pkgs.mise ];

  programs.zsh.initContent = lib.mkMerge [
    (lib.mkOrder 900 ''
      # Mise per-project runtimes (shims only act inside directories that pin tools).
      if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate zsh)"
      fi
    '')
  ];
}
