# SSH program configuration
# This file configures SSH with useful settings

{ config, pkgs, lib, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        Compression = true;
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
      };

      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/github_auth";
        IdentitiesOnly = true;
      };
    };

    extraConfig = ''
      # Connection multiplexing
      ControlMaster auto
      ControlPath ~/.ssh/sockets/%r@%h-%p
      ControlPersist 600

      # Security settings
      Protocol 2
      Ciphers aes128-ctr,aes192-ctr,aes256-ctr
      MACs hmac-sha2-256,hmac-sha2-512

      # Host key verification
      StrictHostKeyChecking ask
      VerifyHostKeyDNS yes

      # X11 forwarding
      ForwardX11 no
      ForwardX11Trusted no
    '';
  };

  home.activation.createSshControlSocketDirectory = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.ssh/sockets"
    $DRY_RUN_CMD chmod 700 "$HOME/.ssh/sockets"
  '';
}
