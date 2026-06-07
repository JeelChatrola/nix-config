# Starship prompt — informative, full path, managed in-repo (no ~/.p10k wizard).

{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = false;

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      username = {
        show_always = true;
        format = "[$user]($style)@";
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname]($style) ";
      };

      directory = {
        truncation_length = 0;
        truncate_to_repo = false;
        fish_style_pwd_dir_length = 0;
        format = "in [$path]($style) ";
        read_only = " ro";
      };

      git_branch = {
        format = "on [$branch]($style) ";
      };

      cmd_duration = {
        min_time = 5000;
        format = "took [$duration]($style) ";
      };

      line_break.disabled = true;
    };
  };
}
