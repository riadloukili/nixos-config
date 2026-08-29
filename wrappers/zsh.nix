# zsh: completion, autosuggestions, syntax highlighting, oh-my-zsh plugins,
# powerlevel10k. Prompt config: <dotfiles>/zsh/p10k.zsh if present, else
# wrappers/defaults/p10k.zsh; <dotfiles>/zsh/zshrc.local is sourced if it exists.
{ wlib, pkgs, ... }:
let
  dot = import ./dotfiles.nix;
  zshDir = "${dot.runtime}/zsh";
in
{
  imports = [ wlib.wrapperModules.zsh ];

  # `env` values are escaped literally (no $HOME expansion): store paths and
  # constants only; $HOME-relative ones are exported in zshrc below.
  env = {
    ZSH = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
    ZSH_DISABLE_COMPFIX = "true";
    HISTSIZE = "50000";
    SAVEHIST = "50000";
  };

  runtimePkgs = with pkgs; [
    eza
    bat
    fzf
    zoxide
  ];

  zshrc.content = ''
    setopt hist_ignore_dups hist_ignore_space share_history extended_history
    setopt auto_cd interactive_comments
    export HISTFILE="$HOME/.zsh_history"
    export ZSH_CACHE_DIR="$HOME/.cache/oh-my-zsh"

    # powerlevel10k instant prompt
    if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
      source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
    fi

    mkdir -p "$ZSH_CACHE_DIR/completions"
    ZSH_THEME=""
    plugins=(git sudo history)
    source "$ZSH/oh-my-zsh.sh"

    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    if [[ -f "${zshDir}/p10k.zsh" ]]; then source "${zshDir}/p10k.zsh"; else source ${./defaults/p10k.zsh}; fi

    eval "$(zoxide init zsh)"
    source ${pkgs.fzf}/share/fzf/key-bindings.zsh
    source ${pkgs.fzf}/share/fzf/completion.zsh

    # Aliases last so they win over oh-my-zsh's defaults.
    alias ls='eza --icons'
    alias ll='eza -l --icons'
    alias la='eza -la --icons'
    alias ..='cd ..'
    alias grep='grep --color=auto'
    alias cat='bat --paging=never'
    alias rebuild='nh os switch'
    alias rebuild-boot='nh os boot'

    [[ -f "${zshDir}/zshrc.local" ]] && source "${zshDir}/zshrc.local"
  '';
}
