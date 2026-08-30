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
        lsd
        jq
        yq-go
        dust
        duf
        ncdu
        fastfetch
        pokemon-colorscripts
        btop
        yazi
        ueberzugpp
        cava
        bc
        figlet
        inotify-tools
        imagemagick
        ffmpeg
        # editors / multiplexer (config from dotfiles)
        neovim
        tmux
        lazygit
        lazydocker
        diff-so-fancy
        nixd
        nixfmt
        sops
        ssh-to-age
        git-lfs
        mkcert
        ast-grep
        mermaid-cli
        awscli2
        azure-cli
        claude-code
        codex
        ccusage
      ]
      ++ lib.optionals desktop [
        # dev toolchains and apps: workstations only
        gh
        glab
        just
        nodejs
        python3
        uv
        go
        rustup
        brave
        discord
        vlc
        (mpv.override { scripts = [ mpvScripts.mpris ]; })
        freecad
        xournalpp
        remmina
      ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
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
      # Keep HM's generated files in $HOME: ~/.config/zsh is my dotfiles' zsh/.
      dotDir = config.home.homeDirectory;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history = {
        path = "${config.home.homeDirectory}/.zsh_history";
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

  # The dots' rofi config and theme selector expect the themes under
  # ~/.local/share/rofi/themes; they live in the dotfiles.
  home.file.".local/share/rofi/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/rofi/themes";

  # GTK/Qt theming comes from the dotfiles (gtk-3.0, gtk-4.0, qt5ct, qt6ct, Kvantum);
  # the cursor theme they name has to be installed and exported here.
  home.pointerCursor = lib.mkIf desktop {
    enable = true;
    gtk.enable = false; # gtk-3.0/settings.ini in the dotfiles already names it
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };
  xdg = {
    enable = true;
    userDirs.enable = desktop;
    mimeApps.enable = desktop;
  };
}
