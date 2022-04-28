{ config, pkgs, lib, etc, ... }:

{
  imports = [
    ../users/wk.nix
  ];

  environment.systemPackages = with pkgs; [
    git
    gnupg
    gnutls
    htop
    tree
    vim
    wget
  ];

  programs = {
    vim = {
      defaultEditor = true;
    };
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [ "git" "sudo" "docker" ];
        theme = "gallifrey";
      };
    };
  };

  users = {
    mutableUsers = false;
  };
}