# riad's home-manager config: my shell, editor and tools. Program configs
# (caelestia, nvim, tmux, ...) come from ~/personal/dotfiles via
# src/modules/dotfiles.nix; anything missing there uses the program's defaults.
{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  dotfiles = config.my.dotfiles.path;
  personal = "${config.home.homeDirectory}/personal";
  desktop = osConfig.programs.hyprland.enable;
  # grim that plays a shutter sound on capture; caelestia's screenshot paths
  # (Print, region, freeze) all shell out to grim, so the CLI is built with
  # this one.
  grim-shutter = pkgs.writeShellScriptBin "grim" ''
    ${pkgs.grim}/bin/grim "$@"
    status=$?
    if [ $status -eq 0 ]; then
      setsid ${pkgs.pipewire}/bin/pw-play \
        ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/screen-capture.oga \
        >/dev/null 2>&1 &
    fi
    exit $status
  '';
  # The shell's own area picker (region/freeze) captures internally and hands
  # off to swappy, so the click comes from a swappy that plays the sound first.
  swappy-shutter = pkgs.writeShellScriptBin "swappy" ''
    setsid ${pkgs.pipewire}/bin/pw-play \
      ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/screen-capture.oga \
      >/dev/null 2>&1 &
    exec ${pkgs.swappy}/bin/swappy "$@"
  '';
  caelestia-cli' =
    inputs.caelestia-shell.inputs.caelestia-cli.packages.${pkgs.system}.default.override
      {
        grim = grim-shutter;
        # Don't bundle the CLI's own copy of the shell: `caelestia shell` must
        # find caelestia-shell on the profile PATH (the overridden one below).
        withShell = false;
      };
in
{
  imports = [ inputs.caelestia-shell.homeManagerModules.default ];

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
        tree-sitter # nvim-treesitter (LazyVim, main branch) compiles parsers with it
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
        (brave.override {
          # screen sharing via the portal, incl. sites still using the legacy getUserMedia screen source
          commandLineArgs = [
            "--enable-features=WebRTCPipeWireCapturer"
            "--enable-usermedia-screen-capturing"
          ];
        })
        discord
        vlc
        (mpv.override { scripts = [ mpvScripts.mpris ]; })
        # The addon manager can't pip-install dependencies into the store, so
        # ship the Python modules addons ask for inside FreeCAD's own
        # interpreter instead (lxml: addon manager; requests: FreeCAD-Ribbon).
        (freecad.customize {
          pythons = [
            (ps: [
              ps.lxml
              ps.requests
            ])
          ];
        })
        xournalpp
        remmina
      ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      STARSHIP_CONFIG = lib.mkForce "${dotfiles}/starship/starship.toml"; # the HM module points at ~/.config/starship.toml
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

  # Paid fonts (Comic Code) come encrypted from secrets/users/riad/fonts.tar.xz;
  # the host decrypts to /run/secrets/riad-fonts, unpack into the user font dir.
  home.activation.privateFonts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -r /run/secrets/riad-fonts ]; then
      run mkdir -p "$HOME/.local/share/fonts/private"
      run ${pkgs.gnutar}/bin/tar -xf /run/secrets/riad-fonts -I ${pkgs.xz}/bin/xz -C "$HOME/.local/share/fonts/private"
      run ${pkgs.fontconfig}/bin/fc-cache -f "$HOME/.local/share/fonts/private" >/dev/null
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
      initContent = ''
        [[ -f "${dotfiles}/zsh/zshrc.local" ]] && source "${dotfiles}/zsh/zshrc.local"
      '';
    };
    starship.enable = true; # prompt; config is the dotfiles' starship/starship.toml

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

  # Desktop shell: caelestia (Quickshell) with its CLI. Their execs.lua starts
  # the shell from Hyprland, so no user service. shell.json and my Hyprland
  # overrides (hypr-vars.lua, hypr-user.lua) are the dotfiles' caelestia/.
  programs.caelestia = lib.mkIf desktop {
    enable = true;
    systemd.enable = false;
    package = inputs.caelestia-shell.packages.${pkgs.system}.with-cli.override {
      caelestia-cli = caelestia-cli';
      swappy = swappy-shutter;
    };
    cli = {
      enable = true;
      package = caelestia-cli';
    };
  };

  # Hyprland config is caelestia's own (flake input, read-only, updated with
  # the lock), linked entry by entry: scheme/current.lua (written by the CLI)
  # and monitors.lua (nwg-displays) stay real files next to them.
  xdg.configFile = lib.mkIf desktop (
    lib.genAttrs
      [
        "hypr/hyprland.lua"
        "hypr/variables.lua"
        "hypr/hyprland"
        "hypr/utils"
        "hypr/scheme/default.lua"
      ]
      (entry: {
        source = "${inputs.caelestia-dots}/${entry}";
      })
  );

  # Wallpapers: a private repo, cloned like the dotfiles; caelestia looks in ~/Pictures/Wallpapers.
  home.file."Pictures/Wallpapers".source =
    config.lib.file.mkOutOfStoreSymlink "${personal}/wallpapers";

  # GTK/Qt theming, icons (Papirus) and the colour scheme are caelestia's
  # (caelestia scheme/wallpaper regenerate them); only the cursor is mine.
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
