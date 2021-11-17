{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cargo
    rustc
    rustfmt
    rust-analyzer
    clippy
  ];
  environment.sessionVariables = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };

}
