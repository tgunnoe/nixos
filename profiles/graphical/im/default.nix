{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    #discord
    #element-desktop
    #signal-desktop
    #slack
    #tdesktop
    gomuks
  ];
}
