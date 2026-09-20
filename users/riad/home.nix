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
  # The LLM CLIs move faster than nixpkgs tracks them (see flake.nix).
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
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
  # Volume keys, with the change made audible the way JaKooLit's config does
  # it with canberra: the freedesktop volume-change sound is played through
  # the sink after a change, so the blip is itself at the new level and tells
  # you how loud things now are. pw-play like the shutter wrappers above,
  # rather than pulling in libcanberra for one sound.
  #
  # The stepping lives here, rather than in the keybind, so the sound can be
  # conditional. One rule covers every case: play when the state actually
  # changed and we are not left muted. At the ceiling wpctl clamps to a no-op,
  # so nothing sounds and the shell's OSD correctly stays hidden; muting is
  # silent because the blip would be inaudible anyway, while unmuting sounds,
  # which is the moment you want to hear the level.
  #
  # 100% is a stop on the way down, wherever above it you started, and also
  # where unmuting lands from higher: that is the unamplified level, and
  # coming back from muted straight to an amplified one is a nasty surprise.
  # Unmuting from silence lands at 50%, since unmuting to nothing audible
  # leaves you pressing keys wondering what broke.
  #
  # The limit and the step are arguments, so hypr-vars.lua stays the one place
  # they are set.
  volume-step = pkgs.writeShellScriptBin "volume-step" ''
    set -eu
    dir=''${1:?usage: volume-step up|down|mute <max> <step>}
    max=''${2:-1}
    step=''${3:-10}
    wpctl=${pkgs.wireplumber}/bin/wpctl
    sink=@DEFAULT_AUDIO_SINK@

    before=$($wpctl get-volume $sink)
    cur=$(echo "$before" | ${pkgs.gawk}/bin/awk '{print $2}')

    case "$dir" in
      up)
        $wpctl set-mute $sink 0
        $wpctl set-volume -l "$max" $sink "$step%+"
        ;;
      down)
        $wpctl set-mute $sink 0
        if ${pkgs.gawk}/bin/awk "BEGIN{exit !($cur > 1)}"; then
          $wpctl set-volume $sink 1
        else
          $wpctl set-volume $sink "$step%-"
        fi
        ;;
      mute)
        $wpctl set-mute $sink toggle
        # Unmuting should give back something usable: above 100% comes back
        # to 100% rather than amplified and loud, and silence comes back at
        # 50% rather than unmuting to nothing audible. Muting is left alone.
        now=$($wpctl get-volume $sink)
        case "$now" in
          *MUTED*) ;;
          *)
            v=$(echo "$now" | ${pkgs.gawk}/bin/awk '{print $2}')
            if ${pkgs.gawk}/bin/awk "BEGIN{exit !($v > 1)}"; then
              $wpctl set-volume $sink 1
            elif ${pkgs.gawk}/bin/awk "BEGIN{exit !($v <= 0)}"; then
              $wpctl set-volume $sink 0.5
            fi
            ;;
        esac
        ;;
      *)
        echo "volume-step: direction must be up, down or mute" >&2
        exit 2
        ;;
    esac

    after=$($wpctl get-volume $sink)
    [ "$before" = "$after" ] && exit 0
    case "$after" in *MUTED*) exit 0 ;; esac

    setsid ${pkgs.pipewire}/bin/pw-play \
      ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/audio-volume-change.oga \
      >/dev/null 2>&1 &
  '';
  # KeePassXC, started once there is a tray to start into. Qt asks the
  # StatusNotifierWatcher to register its icon exactly once, at startup, and
  # does not retry: launched from the Hyprland start hook it beats caelestia's
  # bar to the bus, registers nothing, and since it also starts minimized it
  # looks like it never started at all. Waiting on the well-known name is the
  # honest version of "sleep a bit" -- it proceeds the moment the bar owns it.
  #
  # The timeout is a backstop: if no bar ever appears, still start, so a
  # locked database and browser integration do not depend on the shell.
  keepassxc-tray = pkgs.writeShellScriptBin "keepassxc-tray" ''
    for _ in $(seq 1 100); do
      ${pkgs.systemd}/bin/busctl --user call org.freedesktop.DBus \
        /org/freedesktop/DBus org.freedesktop.DBus NameHasOwner \
        s org.kde.StatusNotifierWatcher 2>/dev/null | grep -q true && break
      sleep 0.2
    done
    exec ${pkgs.keepassxc}/bin/keepassxc "$@"
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
        openfortivpn # needs root for the tun device: sudo openfortivpn
        llm-agents.claude-code
        llm-agents.codex
        llm-agents.ccusage
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
        firefox
        volume-step
        # Browser integration needs a native messaging manifest per browser.
        # KeePassXC writes those itself when you tick a browser under
        # Settings > Browser Integration, and rewrites them at every launch
        # so the proxy's store path stays current. Linking them from the
        # package instead looks tidier but loses: they are then read-only,
        # ticking a browser fails, and unticking it deletes the link outright
        # (removing a symlink only needs write access to the directory).
        keepassxc
        keepassxc-tray
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

  # btop in Catppuccin Macchiato, taken from the packaged catppuccin, which
  # carries that flavour and only that one — no fetch, no hash to keep
  # current.
  #
  # The theme is copied into a derivation of its own rather than handed over
  # as "${pkgs.catppuccin}/btop/...". programs.btop.themes branches on
  # lib.isStorePath, and a store *subpath* fails that test: the option would
  # then treat the path as the theme's text and write the string itself into
  # the file. A derivation whose output is the file passes.
  #
  # Declaring settings makes btop.conf a store symlink, so changes made from
  # inside the TUI stop persisting. Nothing was lost — it still held btop's
  # untouched defaults — but that is the trade for the theme living here.
  # caelestia keeps writing its own caelestia.theme alongside this one from
  # the current colour scheme; it simply goes unselected now.
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "catppuccin_macchiato";
      # Let the terminal show through instead of painting the theme's own
      # base over it — btop's wording: "set to False if you want terminal
      # background transparency". Everything else stays Macchiato.
      theme_background = false;
    };
    themes.catppuccin_macchiato = pkgs.runCommandLocal "btop-catppuccin-macchiato" { } ''
      cp ${pkgs.catppuccin}/btop/catppuccin_macchiato.theme $out
    '';
  };

  # Desktop shell: caelestia (Quickshell) with its CLI. Their execs.lua starts
  # the shell from Hyprland, so no user service. shell.json and my Hyprland
  # overrides (hypr-vars.lua, hypr-user.lua) are the dotfiles' caelestia/.
  programs.caelestia = lib.mkIf desktop {
    enable = true;
    systemd.enable = false;
    # Above 100% the volume is amplified rather than merely loud, so the OSD
    # slider goes red there. caelestia has no setting for it and the QML is in
    # the store, so the one colour in FilledSlider is patched. --replace-fail
    # means an upstream change to that line breaks the build rather than
    # quietly dropping the cue. FilledSlider is the OSD's alone, and the
    # brightness slider that shares it cannot exceed 1, so nothing else reddens.
    package =
      (inputs.caelestia-shell.packages.${pkgs.system}.with-cli.override {
        caelestia-cli = caelestia-cli';
        swappy = swappy-shutter;
      }).overrideAttrs
        (prev: {
          postPatch = (prev.postPatch or "") + ''
            substituteInPlace components/controls/FilledSlider.qml \
              --replace-fail 'color: Colours.palette.m3secondary' \
                'color: root.value > 1 ? Colours.palette.m3error : Colours.palette.m3secondary'
          '';
        });
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

  # Mount removable drives on plug. udisks2 will do it but nothing asks it to:
  # there is no desktop volume manager here, and caelestia's shell does not
  # handle disks. No tray icon — the bar is caelestia's.
  services.udiskie = lib.mkIf desktop {
    enable = true;
    tray = "never";
  };

  # Wallpapers: a private repo, cloned like the dotfiles; caelestia looks in ~/Pictures/Wallpapers.
  home.file."Pictures/Wallpapers".source =
    config.lib.file.mkOutOfStoreSymlink "${personal}/wallpapers";

  # GTK/Qt theming, icons (Papirus) and the colour scheme are caelestia's
  # (caelestia scheme/wallpaper regenerate them); only the cursor and the UI
  # font are mine.
  #
  # The font matters beyond GTK apps: Firefox resolves CSS system-ui through
  # GTK's font setting, and with nothing set about:newtab and the onboarding
  # page fall back to its built-in serif. caelestia writes only gtk.css, so
  # settings.ini is free for us.
  gtk = lib.mkIf desktop {
    enable = true;
    font = {
      name = "Google Sans"; # what sans-serif already resolves to here
      size = 11;
    };
  };
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
