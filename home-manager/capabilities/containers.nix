{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    lazydocker
    dive
    ctop
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    docker
    docker-compose
  ];
}
