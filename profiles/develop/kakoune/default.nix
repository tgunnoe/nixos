{ pkgs, ... }: {
  imports = [ ../python ];

  environment.systemPackages = with pkgs; [
    clang-tools
    kak-lsp
    kakoune-config
    kakoune-unwrapped
    nixpkgs-fmt
    python3Packages.python-language-server
    rustup
    nix-linter
    dhall
    dhall-lsp-server
  ];

  environment.etc = {
    "xdg/kak-lsp/kak-lsp.toml".text = ''
      ${builtins.readFile "${pkgs.kak-lsp.src}/kak-lsp.toml"}
      [language.dhall]
      filetypes = ["dhall"]
      roots = [".git"]
      command = "dhall-lsp-server"
    '';
    "xdg/kak/kakrc".source = ./kakrc;
    "xdg/kak/autoload/plugins".source = ./plugins;
    "xdg/kak/autoload/lint".source = ./lint;
    "xdg/kak/autoload/lsp".source = ./lsp;
    "xdg/kak/autoload/default".source =
      "${pkgs.kakoune-unwrapped}/share/kak/rc";
  };
}
