{ config, lib, pkgs, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
  };
}
