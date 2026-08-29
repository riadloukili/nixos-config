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
    };
  };

  # My SSH keypair comes from secrets/users/riad.yaml (decrypted by the host to
  # /run/secrets/riad-ssh-key); install it, then derive my sops age identity from it.
  home.activation.identity = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -r /run/secrets/riad-ssh-key ]; then
      run mkdir -p -m 700 "$HOME/.ssh"
      run install -m 600 /run/secrets/riad-ssh-key "$HOME/.ssh/id_ed25519"
      run ${pkgs.openssh}/bin/ssh-keygen -y -f "$HOME/.ssh/id_ed25519" > "$HOME/.ssh/id_ed25519.pub"
    fi
    if [ -f "$HOME/.ssh/id_ed25519" ] && [ ! -f "$HOME/.config/sops/age/keys.txt" ]; then
      if ! ${pkgs.openssh}/bin/ssh-keygen -y -P "" -f "$HOME/.ssh/id_ed25519" >/dev/null 2>&1; then
        echo "sops: SSH key has a passphrase; derive the age identity once by hand:" >&2
        echo "  SSH_TO_AGE_PASSPHRASE=... ssh-to-age -private-key -i ~/.ssh/id_ed25519 -o ~/.config/sops/age/keys.txt" >&2
      else
        run mkdir -p -m 700 "$HOME/.config/sops/age"
        run ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i "$HOME/.ssh/id_ed25519" -o "$HOME/.config/sops/age/keys.txt"
        run chmod 600 "$HOME/.config/sops/age/keys.txt"
      fi
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
