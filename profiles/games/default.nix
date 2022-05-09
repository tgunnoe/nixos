{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    #retroarchBare
    #pcsx2
    devilutionx
    factorio
    openra
    openal
    gzdoom
    steam-tui
    steamcmd
    #lzwolf
    faforever
    steam-run
    #spring
    #springLobby
    lutris
    wine
    winetricks
  ];

  programs.steam.enable = true;

  # fps games on laptop need this
  #services.xserver.libinput.touchpad.disableWhileTyping = false;

  #services.xserver.windowManager.steam = { enable = true; };

  # 32-bit support needed for steam
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.pulseaudio.support32Bit = true;

  # better for steam proton games
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";

  # improve wine performance
  environment.sessionVariables = { WINEDEBUG = "-all"; };
}
