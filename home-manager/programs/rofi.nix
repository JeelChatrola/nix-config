{
  config,
  lib,
  pkgs,
  ...
}:

let
  terminalBinding = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-terminal/";
  launcherBinding = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/rofi-launcher/";
  rofi = "${config.programs.rofi.finalPackage}/bin/rofi";

  rofiActions = pkgs.writeShellApplication {
    name = "rofi-actions";
    runtimeInputs = with pkgs; [
      clipmenu
      jq
      systemd
      xdg-utils
    ];
    text = ''
      confirm() {
        local answer
        answer="$(printf 'No\nYes\n' | ${rofi} -dmenu -p "$1")"
        [[ "$answer" == "Yes" ]]
      }

      if [[ $# -eq 0 ]]; then
        printf '%s\n' \
          "Clipboard history" \
          "Emoji picker" \
          "Browse files" \
          "Search the web" \
          "Lock screen" \
          "Suspend" \
          "Restart" \
          "Power off"
        exit 0
      fi

      case "$1" in
        "Clipboard history")
          exec env CM_LAUNCHER=rofi clipmenu -p "Clipboard"
          ;;
        "Emoji picker")
          exec ${rofi} -show emoji
          ;;
        "Browse files")
          exec ${rofi} -show filebrowser
          ;;
        "Search the web")
          query="$(${rofi} -dmenu -p "Web search" </dev/null)"
          if [[ -n "$query" ]]; then
            encoded="$(jq -rn --arg query "$query" '$query | @uri')"
            xdg-open "https://www.google.com/search?q=$encoded" >/dev/null 2>&1 &
          fi
          ;;
        "Lock screen")
          loginctl lock-session
          ;;
        "Suspend")
          confirm "Suspend?" && systemctl suspend
          ;;
        "Restart")
          confirm "Restart?" && systemctl reboot
          ;;
        "Power off")
          confirm "Power off?" && systemctl poweroff
          ;;
      esac
    '';
  };
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
    ];
    font = "JetBrainsMono Nerd Font 12";
    theme = "gruvbox-dark-hard";

    extraConfig = {
      modi = "combi,drun,run,window,calc,filebrowser,emoji,actions:${rofiActions}/bin/rofi-actions";
      combi-modes = "drun,run,window,calc";
      show-icons = true;
      display-combi = "Search";
      display-drun = "Apps";
      display-run = "Run";
      display-window = "Windows";
      display-calc = "Calculate";
      display-filebrowser = "Files";
      display-emoji = "Emoji";
      display-actions = "Actions";
      drun-display-format = "{icon} {name}";
      kb-mode-next = "Control+Tab";
      kb-mode-previous = "Control+ISO_Left_Tab";
    };
  };

  home.packages = [ rofiActions ];

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/rofi-launcher" = {
      name = "Rofi Launcher";
      command = "${rofi} -show combi";
      binding = "<Control>space";
    };
  };

  home.activation.registerRofiShortcut = lib.hm.dag.entryAfter [ "dconfSettings" ] ''
    registry="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
    current="$(${pkgs.dconf}/bin/dconf read "$registry")"

    add_binding() {
      local path="$1"
      if [[ "$current" == *"$path"* ]]; then
        return
      fi
      if [[ -z "$current" || "$current" == "@as []" || "$current" == "[]" ]]; then
        current="['$path']"
      else
        current="''${current%]}, '$path']"
      fi
    }

    terminal_command="$(${pkgs.dconf}/bin/dconf read \
      "${terminalBinding}command")"
    if (( ''${#terminal_command} > 2 )); then
      add_binding "${terminalBinding}"
    fi
    add_binding "${launcherBinding}"
    ${pkgs.dconf}/bin/dconf write "$registry" "$current"
  '';

  systemd.user.services.clipmenud = {
    Unit = {
      Description = "Clipboard history daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.clipmenu}/bin/clipmenud";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
