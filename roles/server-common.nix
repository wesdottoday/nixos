{ config, lib, pkgs, ... }:
{
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      authorizedKeys = config.users.users.wk.openssh.authorizedKeys.keys;
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 22 2222 ];
  };

  services = {
    fail2ban = {
      enable = true;
    };
    openssh = {
      enable = true;
      permitRootLogin = "no";
      passwordAuthentication = false;
      authorizedKeys = config.users.users.wk.openssh.authorizedKeys.keys;
    };
  };
}
