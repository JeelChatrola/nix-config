# SSH program configuration
# This file configures SSH with useful settings

{ config, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;  # Disable deprecated defaults
    
    # Set default values explicitly (replaces deprecated defaults)
    matchBlocks."*" = {
      forwardAgent = true;
      compression = true;
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
    };
    
    # GitHub SSH configuration
    matchBlocks."github.com" = {
      hostname = "github.com";
      user = "git";
      identityFile = "~/.ssh/github_auth";
      identitiesOnly = true;
    };
    
    # Additional SSH configuration
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
      ForwardX11 yes
      ForwardX11Trusted yes
    '';
  };
  
  # SSH will create the sockets directory automatically when needed
  # No need to manage it with home-manager
}
