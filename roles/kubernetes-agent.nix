{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./.];

  sops.secrets.k3s-server-token.sopsFile = ./secrets.yml;
  services = {
    k3s = {
      role = "agent";
      # generated random string
      tokenFile = lib.mkDefault config.sops.secrets.k3s-server-token.path;
      serverAddr = lib.mkDefault "https://astrid.dse.in.tum.de:6443";
      extraFlags = "--node-ip ${config.networking.doctorwho.currentHost.ipv4} --snapshotter=zfs --container-runtime-endpoint unix:///run/containerd/containerd.sock";
    };
  };
}