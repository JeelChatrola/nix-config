# GNOME Desktop Environment Configuration
# This manages GNOME settings via dconf (declarative)
# Install themes/extensions via system package manager separately

{ config, pkgs, lib, ... }:

{
  # GTK Configuration
  gtk = {
    enable = true;
    
    # Gruvbox Dark theme (install system theme first)
    theme = {
      name = "Gruvbox-Dark";
    };
    
    iconTheme = {
      name = "Papirus-Dark";
    };
    
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    
    # GTK3 settings
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    
    # GTK4 settings
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
  
  # GNOME Settings via dconf (this is what Home Manager excels at)
  dconf.settings = {
    # Interface preferences
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Gruvbox-Dark";
      icon-theme = "Papirus-Dark";
      cursor-theme = "Bibata-Modern-Classic";
      font-name = "Inter 11";
      document-font-name = "Inter 11";
      monospace-font-name = "MesloLGS Nerd Font Mono 10";
      enable-hot-corners = false;
    };
    
    # Window Manager preferences
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      theme = "Gruvbox-Dark";
      titlebar-font = "Inter Bold 11";
    };
    
    # Window Manager Keybindings (Pop Shell compatible)
    "org/gnome/desktop/wm/keybindings" = {
      # Close window
      close = ["<Super>q"];
      
      # Maximize/minimize
      toggle-maximized = ["<Super>m"];
      minimize = ["<Super>comma"];
      
      # Move to workspace
      move-to-workspace-left = ["<Shift><Super>Left"];
      move-to-workspace-right = ["<Shift><Super>Right"];
      
      # Switch workspace
      switch-to-workspace-left = ["<Super>Left"];
      switch-to-workspace-right = ["<Super>Right"];
    };
    
    # Custom Keybindings
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
      ];
      
      # Built-in shortcuts
      home = ["<Super>f"];
      www = ["<Super>b"];
      email = ["<Super>e"];
      screensaver = ["<Super>Escape"];
    };
    
    # Terminal launcher
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Terminal";
      command = "alacritty";
      binding = "<Super>t";
    };
    
    # Application launcher
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "Launcher";
      command = "rofi -show drun";
      binding = "<Super>space";
    };
    
    # File manager
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      name = "Files";
      command = "nautilus";
      binding = "<Super>e";
    };
    
    # Shell Extensions (Pop Shell will be configured here)
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "pop-shell@system76.com"
        # Add other extensions as needed
      ];
      favorite-apps = [
        "alacritty.desktop"
        "firefox.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };
    
    # Pop Shell Settings (only if Pop Shell is installed)
    "org/gnome/shell/extensions/pop-shell" = {
      tile-by-default = true;
      active-hint = true;
      active-hint-border-radius = lib.hm.gvariant.mkUint32 8;
      gap-inner = lib.hm.gvariant.mkUint32 2;
      gap-outer = lib.hm.gvariant.mkUint32 2;
      smart-gaps = true;
      show-title = false;
    };
    
    # Mutter (Window Manager) settings
    "org/gnome/mutter" = {
      edge-tiling = true;
      dynamic-workspaces = true;
      workspaces-only-on-primary = false;
    };
    
    # Terminal settings
    "org/gnome/terminal/legacy" = {
      theme-variant = "dark";
    };
  };
}

