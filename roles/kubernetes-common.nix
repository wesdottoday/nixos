{ config, lib, pkgs, ... }: let in {
  config = {
    services = {
      k3s = {
        enable = true;
        docker = lib.mkForce false;
      };
    };
    virtualisation.containerd = {
      enable = true;
      settings = {
        version = 2;
        plugins."io.containerd.grpc.v1.cri" = {
          cni.conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
          # FIXME: upstream
          cni.bin_dir = "${pkgs.runCommand "cni-bin-dir" {} ''
            mkdir -p $out
            ln -sf ${pkgs.cni-plugins}/bin/* ${pkgs.cni-plugin-flannel}/bin/* $out
          ''}";
        };
      };
    };

    # Networking and Firewall
    networking = {
      firewall = {
        enable = true;
        allowedTCPPorts = [
          22 6443
        ];
        allowedUDPPorts = [

        ];
      };
    };

    # Passwordless sudo
    security.sudo.extraConfig = ''
      %wheel         ALL = (ALL) NOPASSWD: ALL
    '';

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ../files/k3s-reset-node))
    ];

    systemd.services.k3s = {
      wants = ["containerd.service"];
      after = ["containerd.service"];
    };

    systemd.services.containerd.serviceConfig = {
      ExecStartPre = [
        "-${pkgs.zfs}/bin/zfs create -o mountpoint=/var/lib/containerd/io.containerd.snapshotter.v1.zfs zroot/containerd"
      ];
    };
  };
}