{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    git-lfs
    nodejs_24
    lazygit
    gh
    bear
    ccache
    cmake
    ninja
    gnumake
    pkg-config
    clang-tools
    lldb
    python3
    python3Packages.pip
    python3Packages.virtualenv
    uv
    ruff
    magika
    python313Packages.markitdown
    ffmpeg
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    gcc
    gdb
    man-pages
    man-db
  ];
}
