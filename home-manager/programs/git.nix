# Git program configuration
# This file configures git with custom settings

{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "jeel";
    userEmail = "jeel@example.com"; # Update this with your actual email
    
    # Import git config from external file
    extraConfig = builtins.readFile ../configs/gitconfig;
  };
}
