{ host, identity, ... }:

{
  nixpkgs.hostPlatform = host.system;

  system = {
    primaryUser = identity.username;
    stateVersion = 6;
  };

  users.users.${identity.username}.home = host.homeDirectory;
}
