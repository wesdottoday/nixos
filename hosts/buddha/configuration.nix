{ config, pkgs, lib, etc, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../roles/common.nix
      ../../roles/server-common.nix
    ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        version = 2;
        device = "nodev";
        efiSupport = true;
        enableCryptodisk = true;
      };
    }; 
    initrd = {
      root = {
        device = "/dev/disk/by-uuid/UUID";
        preLVM = true;
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      git
      htop
      tree
      vim
    ];
  };

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

  networking = {
    hostId = "ABBABBA1";
    hostName = "buddha";
    useDHCP = false;
    interfaces = {
      enp113s0 = {
        useDHCP = false;
        ipv4.addresses = {
          address = "10.99.9.30"
          prefixLength = 24;
        };
      };
    };
    defaultGateway = "10.99.9.1";
    nameservers = [
      "10.99.9.1"
    ];
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Users
  users = {
    motd = "\n###############################################################################################################################\n# Buddha, in Buddhism, is someone who has become awake through their own efforts and insight.                      #\n# Buddha is one of The Three Jewels, which are a part of Buddhism that people take spiritual refuge in.  #\n############################################################################################################################### ";
    mutableUsers = false;
    users = {
      wk = {
        isNormalUser = true;
        extraGroups = [ "wheel" "video" "audio" "disk" ];
        hashedPassword = "$1$CvP3BCuv$IEXht3IldXf.jTfQgwGIe1";
        uid = 1000;
        shell = pkgs.zsh;
      };
    };
  };
 
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

