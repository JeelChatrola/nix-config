# SSH program configuration
# This file configures SSH with useful settings

{ config, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    
    # Global SSH configuration
    extraConfig = ''
      # Keep connections alive
      ServerAliveInterval 60
      ServerAliveCountMax 3
      
      # Compression
      Compression yes
      
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
      
      # Common settings
      ForwardAgent yes
      ForwardX11 yes
      ForwardX11Trusted yes
    '';
  };
  
  # Create SSH directory and sockets directory
  home.file.".ssh/sockets".source = pkgs.runCommand "ssh-sockets-dir" {} ''
    mkdir -p $out
  '';
}
