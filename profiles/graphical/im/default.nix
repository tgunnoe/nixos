{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    element-desktop
    signal-desktop
    slack
    tdesktop
    gomuks
  ];
}
