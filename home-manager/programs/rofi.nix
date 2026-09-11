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
      coreutils
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

      # --launch is the supported entry point; script mode only hands selections back to this controller.
      if [[ "''${1:-}" == "--launch" ]]; then
        request_file="$(mktemp --tmpdir="''${XDG_RUNTIME_DIR:-/tmp}" rofi-actions.XXXXXX)"
        trap 'rm -f "$request_file"' EXIT

        state="launcher"
        while [[ -n "$state" ]]; do
          case "$state" in
            launcher)
              : >"$request_file"
              if ! ROFI_ACTION_FILE="$request_file" ${rofi} -show combi; then
                exit 0
              fi
              state=""
              IFS= read -r state <"$request_file" || true
              ;;
            "Clipboard history")
              env CM_LAUNCHER=rofi clipmenu -p "Clipboard" || true
              state=""
              ;;
            "Emoji picker")
              ${rofi} -show emoji || true
              state=""
              ;;
            "Browse files")
              ${rofi} -show filebrowser || true
              state=""
              ;;
            "Search the web")
              if query="$(${rofi} -dmenu -p "Web search" </dev/null)" && [[ -n "$query" ]]; then
                encoded="$(jq -rn --arg query "$query" '$query | @uri')"
                xdg-open "https://www.google.com/search?q=$encoded" >/dev/null 2>&1 &
              fi
              state=""
              ;;
            "Lock screen")
              loginctl lock-session
              state=""
              ;;
            "Suspend")
              confirm "Suspend?" && systemctl suspend
              state=""
              ;;
            "Restart")
              confirm "Restart?" && systemctl reboot
              state=""
              ;;
            "Power off")
              confirm "Power off?" && systemctl poweroff
              state=""
              ;;
            *)
              state=""
              ;;
          esac
        done
        exit 0
      fi

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

      if [[ -n "''${ROFI_ACTION_FILE:-}" ]]; then
        printf '%s\n' "$1" >"$ROFI_ACTION_FILE"
      fi
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
      command = "${rofiActions}/bin/rofi-actions --launch";
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
    run ${pkgs.dconf}/bin/dconf write "$registry" "$current"
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
