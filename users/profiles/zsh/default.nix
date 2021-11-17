{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableVteIntegration = true;
    autocd = true;
    dotDir = ".config/zsh";
    defaultKeymap = "emacs";
    history = {
      extended = true;
      ignoreDups = true;
    };
    initExtraFirst = "
      [[ $TERM == \"dumb\" ]] && unsetopt zle && PS1='$ ' && return
      ZSH_DISABLE_COMPFIX=true\n
    ";
    initExtra = "
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme\n

    ";
    sessionVariables = { RPROMPT = ""; };

    shellAliases = {
      "ls" = "ls --color --group-directories-first";
      t = "cd $(mktemp -d)";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
      theme = "crcandy";

    };

    plugins = [
      {
        name = "powerlevel10k-config";
        src = pkgs.substituteAll { src = ./p10k-linux.zsh; dir = "bin"; };
        file = "bin/p10k-linux.zsh";
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "autopair";
        file = "autopair.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "4039bf142ac6d264decc1eb7937a11b292e65e24";
          sha256 = "02pf87aiyglwwg7asm8mnbf9b2bcm82pyi1cj50yj74z4kwil6d1";
        };
      }
      {
        name = "fast-syntax-highlighting";
        file = "fast-syntax-highlighting.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "v1.28";
          sha256 = "106s7k9n7ssmgybh0kvdb8359f3rz60gfvxjxnxb4fg5gf1fs088";
        };
      }
      {
        name = "pi-theme";
        file = "pi.zsh-theme";
        src = pkgs.fetchFromGitHub {
          owner = "tobyjamesthomas";
          repo = "pi";
          rev = "96778f903b79212ac87f706cfc345dd07ea8dc85";
          sha256 = "0zjj1pihql5cydj1fiyjlm3163s9zdc63rzypkzmidv88c2kjr1z";
        };
      }
      {
        name = "z";
        file = "zsh-z.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "agkozak";
          repo = "zsh-z";
          rev = "41439755cf06f35e8bee8dffe04f728384905077";
          sha256 = "1dzxbcif9q5m5zx3gvrhrfmkxspzf7b81k837gdb93c4aasgh6x6";
        };
      }
    ];
  }; # /zsh

}
