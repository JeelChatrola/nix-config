{ host, identity, ... }:

{
  nixpkgs.hostPlatform = host.system;

  # The locked nix-darwin HTML generator is incompatible with nixos-render-docs.
  documentation.doc.enable = false;

  system = {
    primaryUser = identity.username;
    stateVersion = 6;
  };

  users.users.${identity.username}.home = host.homeDirectory;
}
