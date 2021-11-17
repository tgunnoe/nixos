{ pkgs, lib, ... }: {
  services.openssh = {
    enable = true;
    challengeResponseAuthentication = false;
    passwordAuthentication = false;
    forwardX11 = true;
    permitRootLogin = lib.mkDefault "no";
    startWhenNeeded = true;
  };
  environment.systemPackages = with pkgs; [
    sshfs
  ];
}
