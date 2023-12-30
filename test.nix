{ config, pkgs, ... }: {
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=100%" ];
    };
  };
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  environment.defaultPackages = with pkgs; [ joypixels config.nur.repos.milahu.cmix ];
}
