# Git program configuration
# This file configures git with custom settings

{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "JeelChatrola";
    userEmail = "jeelchatrola046@gmail.com"; # Update this with your actual email
    
    # Git configuration as attribute set (not string)
    extraConfig = {
      init.defaultBranch = "main";
      
      pull.rebase = false;
      
      core = {
        editor = "nvim";
        autocrlf = "input";
        whitespace = "trailing-space,space-before-tab";
      };
      
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      
      alias = {
        # Basic aliases
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        df = "diff";
        lg = "log --oneline --graph --decorate --all";
        ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
        
        # Advanced aliases
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "!gitk";
        amend = "commit --amend";
        wipe = "!git add -A && git commit -qm 'WIPE SAVEPOINT' && git reset HEAD~1 --hard";
        
        # Branch management
        bd = "branch -d";
        bD = "branch -D";
        recent = "for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(committerdate:short)'";
        
        # Remote management
        rv = "remote -v";
        rp = "remote prune origin";
        
        # Stash management
        sl = "stash list";
        sp = "stash pop";
        ss = "stash save";
      };
      
      color = {
        ui = "auto";
        branch = "auto";
        diff = "auto";
        status = "auto";
      };
      
      "color \"branch\"" = {
        current = "yellow reverse";
        local = "yellow";
        remote = "green";
      };
      
      "color \"diff\"" = {
        meta = "yellow bold";
        frag = "magenta bold";
        old = "red bold";
        new = "green bold";
      };
      
      "color \"status\"" = {
        added = "yellow";
        changed = "green";
        untracked = "cyan";
      };
    };
  };
}
