{ config, ... }:

{
  users.users.wk = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "audio" "disk" ];
      hashedPassword = "$1$CvP3BCuv$IEXht3IldXf.jTfQgwGIe1";
      uid = 1000;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGk2RFfsseosarO2lCH7qa917jKcyc313B7RStOeCWty wk@wes.today"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAXcXs/del3FOoagJRSR843y0XBMLaXMq/K+imW4P4iT wkennedy@nvidia.com"
      ]
  };
}
