# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, etc, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
  };

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/6e268424-e2d3-45b1-aeec-141887b55ef2";
      preLVM = true;
    };
  };

  # Rollback to blank root
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

  # Symlink NixOS Config Directory
  environment.etc."nixos" = {
    source = "/persist/etc/nixos/";
  };

  systemd.tmpfiles.rules = [
    "L /root/.ssh - - - - /persist/root/.ssh"
    "L /root/borgbackup - - - - /persist/root/borgbackup"
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "dropbox"
      "google-chrome"
    ];
 

  environment.systemPackages = with pkgs; [
    bitwarden
    dropbox
    dropbox-cli
    firefox
    git
    google-chrome
    htop
    tree
    tusk
    vim
  ];

  programs = {
    vim = {
      defaultEditor = true;
      plugins = with pkgs.vimPlugins; [ "NERDtree" ];
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
    hostId = "7999E84E";
    hostName = "samsara";
    useDHCP = false;
    interfaces = {
      enp0s31f6.useDHCP = true;
      wlp61s0.useDHCP = true;
    };
    wireless = {
      enable = true;
      userControlled.enable = true;
      networks = {
        kilo-home = {
          pskRaw = "b93ea05a2d39651e28d54ae60e16df90db4581d632e49a5695d3f0708bbccd72";
        };
        WorthingtonLibraries = {};
      };
    };
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Users
  users.motd = "\n###############################################################################################################################\n# Samsara, in Buddhism, means _wandering_ or _world_, with the connotation of cyclic, circuitous change.                      #\n# It refers to the theory of rebirth and _cyclicality of all life, matter, existence_, a fundamental assumption of Buddhism.  #\n############################################################################################################################### ";

  # Backups
  services.borgbackup.jobs."borgbase" = {
    paths = [
      "/home"
      "/persist"
    ];
    exclude = [];
    repo = "w9umk9cz@w9umk9cz.repo.borgbase.com:repo";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /persist/root/borgbackup/passphrase";
    };
    environment.BORG_RSH = "ssh -i /persist/root/borgbackup/ssh_key";
    compression = "auto,lzma";
    startAt = "hourly";
    prune.keep = {
      within = "1d";
      daily = 7;
      weekly = 4;
      monthly = -1;
    };
  }; 

  # Containers
  virtualisation = { 
    podman = {
      enable = true;
      extraPackages = [ pkgs.zfs ];
      dockerCompat = true;
    };
  };

  # SSH Configuration
  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/persist/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };
 
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  
  # Window Manager and Desktop Manager
  services.xserver = {
    enable = true;
    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
      };
    };
    windowManager.i3.enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    displayManager.defaultSession = "xfce+i3";
  };

    
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

