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
  environment.defaultPackages = with pkgs; [ nixpkgs-23_11.google-chrome joypixels cmix ];
}
