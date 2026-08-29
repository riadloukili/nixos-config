# riad's home-manager config: my shell, editor and tools. Program configs
# (hypr, waybar, nvim, tmux, ...) come from ~/personal/dotfiles via
# modules/dotfiles.nix; anything missing there uses the program's defaults.
{
  config,
  osConfig,
  pkgs,
  ...
}:
let
  dotfiles = config.my.dotfiles.path;
in
{
  home = {
    username = "riad";
    homeDirectory = "/home/riad";
    stateVersion = osConfig.system.stateVersion;

    packages = with pkgs; [
      # cli
      curl
      wget
      tree
      unzip
      ripgrep
      fd
      bat
      eza
      jq
      yq-go
      dust
      duf
      fastfetch
      btop
      # editors / multiplexer (config from dotfiles)
      neovim
      tmux
      # dev
      gh
      glab
      just
      nodejs
      python3
      uv
      go
      rustup
      lazygit
      lazydocker
      docker-compose
      nixd
      nixfmt
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      ls = "eza --icons";
      ll = "eza -l --icons";
      la = "eza -la --icons";
      cat = "bat --paging=never";
      rebuild = "nh os switch";
    };
  };

  programs = {
    home-manager.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history = {
        size = 50000;
        ignoreDups = true;
        ignoreSpace = true;
      };
      oh-my-zsh = {
        enable = true;
        theme = "";
        plugins = [
          "git"
          "sudo"
          "history"
        ];
      };
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
      ];
      initContent = ''
        [[ -f "${dotfiles}/zsh/p10k.zsh" ]] && source "${dotfiles}/zsh/p10k.zsh"
        [[ -f "${dotfiles}/zsh/zshrc.local" ]] && source "${dotfiles}/zsh/zshrc.local"
      '';
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "Riad Loukili";
          email = "me@riad.ca";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = false; # atuin owns Ctrl-R; fzf stays available as a command
    };
    zoxide.enable = true;
    atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
    };
    kitty.enable = true;
  };

  # Desktop theming (only matters on desktop hosts).
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };
  gtk = {
    enable = true;
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };
  xdg = {
    enable = true;
    userDirs.enable = true;
    mimeApps.enable = true;
  };
}
