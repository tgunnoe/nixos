{ pkgs, ... }: {
  virtualisation = {
    libvirtd = {
      enable = true;
      qemuRunAsRoot = false;
      allowedBridges = [
        "virbr0"
        "virbr1"
      ];
    };
    anbox.enable = false;
    containers.enable = true;
    waydroid.enable = true;
  };
  networking.firewall.trustedInterfaces = [ "waydroid0" ];
  # you'll need to add your user to 'libvirtd' group to use virt-manager
  environment.systemPackages = with pkgs; [ virt-manager ];

  #environment.shellAliases.docker = "podman";

  # environment.sessionVariables = {
  #   VAGRANT_DEFAULT_PROVIDER = "libvirt";
  # };
}
