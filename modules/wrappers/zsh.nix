# zsh with completion, autosuggestions, syntax highlighting, a few oh-my-zsh
# plugins and powerlevel10k. The prompt config comes from the dotfiles
# checkout (`<dotfiles>/zsh/p10k.zsh`) when present, otherwise from
# modules/wrappers/defaults/p10k.zsh; `<dotfiles>/zsh/zshrc.local` is
# sourced if it exists.
{ config, ... }:
let
  dot = config.flake.dotfiles;
  zshDir = if dot.store != null then "${dot.store}/zsh" else "${dot.runtime}/zsh";
  defaultP10k = ./defaults/p10k.zsh;
in
{
  flake.wrappers.zsh =
    { wlib, pkgs, ... }:
    {
      imports = [ wlib.wrapperModules.zsh ];

      # `env` values are escaped literally (no $HOME expansion): only
      # store paths and constants go here; $HOME-relative ones are exported in zshrc.
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
        if [[ -f "${zshDir}/p10k.zsh" ]]; then source "${zshDir}/p10k.zsh"; else source ${defaultP10k}; fi

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
    };
}
