{ config, lib, pkgs, ... }: {
  imports = [
  
  ];

  system = {
    stateVersion = "21.11";
    autoUpgrade = {
      enable = true;
      allowReboot = false;
    };
  };

  # Kubernetes
  services = {
    k3s = {
      enable = true;
      docker = lib.mkForce false;
      extraFlags = "--no-deploy traefik --flannel-backend=host-gw --snapshotter=zfs --container-runtime-endpoint unix:///run/containerd/containerd.sock";
    };
  };
}