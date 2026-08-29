# riad's home-manager config: my shell, editor and tools. Program configs
# (hypr, waybar, nvim, tmux, ...) come from ~/personal/dotfiles via
# src/modules/dotfiles.nix; anything missing there uses the program's defaults.
{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  dotfiles = config.my.dotfiles.path;
  desktop = osConfig.programs.hyprland.enable;
in
{
  home = {
    username = "riad";
    homeDirectory = "/home/riad";
    stateVersion = osConfig.system.stateVersion;

    packages =
      with pkgs;
      [
        # cli
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
        lazygit
        lazydocker
        nixd
        nixfmt
      ]
      ++ lib.optionals desktop [
        # dev toolchains: workstations only
        gh
        glab
        just
        nodejs
        python3
        uv
        go
        rustup
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
      # Derive my sops age identity from ~/.ssh/id_ed25519 (asks for the passphrase).
      sops-identity = "mkdir -p -m 700 ~/.config/sops/age && read -rs 'SSH_TO_AGE_PASSPHRASE?SSH key passphrase: ' && echo && SSH_TO_AGE_PASSPHRASE=$SSH_TO_AGE_PASSPHRASE ssh-to-age -private-key -i ~/.ssh/id_ed25519 -o ~/.config/sops/age/keys.txt && chmod 600 ~/.config/sops/age/keys.txt && echo 'age identity written to ~/.config/sops/age/keys.txt'";
    };
  };

  # My SSH keypair comes from secrets/users/riad.yaml (decrypted by the host to
  # /run/secrets/riad-ssh-key{,-pub}); install the pair in ~/.ssh at activation.
  home.activation.sshKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -r /run/secrets/riad-ssh-key ]; then
      run mkdir -p -m 700 "$HOME/.ssh"
      run install -m 600 /run/secrets/riad-ssh-key "$HOME/.ssh/id_ed25519"
      run install -m 644 /run/secrets/riad-ssh-key-pub "$HOME/.ssh/id_ed25519.pub"
    fi
  '';

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
  };

  # Desktop theming.
  home.pointerCursor = lib.mkIf desktop {
    enable = true;
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };
  gtk = lib.mkIf desktop {
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
  qt = lib.mkIf desktop {
    enable = true;
    platformTheme.name = "gtk3";
  };
  xdg = {
    enable = true;
    userDirs.enable = desktop;
    mimeApps.enable = desktop;
  };
}
