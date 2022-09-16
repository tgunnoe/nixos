{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    electrum
  ];
  services.trezord.enable = true;
  hardware.ledger.enable = true;
}
