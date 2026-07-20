{ lib, pkgs, ... }:

{
  imports = [ ../programs/ai-tools.nix ];

  home.packages = [
    pkgs.llmfit
  ] ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
    pkgs.rtk
  ];
}
