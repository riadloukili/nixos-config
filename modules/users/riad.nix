{
  users.users.riad = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDVAlLxIukRuOf8cR+IqnghXKScM6zkwXL5DoaHc6n5cOabI08RpbfbbIlc0Sz6EVUiB0pEbMtSdvgejjlR8Gr4ve49jj6t7E/4p9seTI9Cv8nsz69Eh10uP/m7I8BLWlXmQlHqSmVvrJz5H+gv7w0jlC4zETrYx3M2ayXFUAbjDEGnnSOoXGGroUVYed2mjlXAuGlhrxzmJWzyPk1H5AVmMjvphEVF6NqeruLO2Oo23r74yqqvDgvRhLEwGKFIUEnVdRnX9MIR0NoP4oBKbT1kxFt4J+bAC8u3MSkj3CRsDKAoug1eoLzc1XJ1NuDjQ0bpQyxVGv2LsbBJs0P1zOoGsuPP3//mMQeWVaEkNpFoiBMQeJydxGsIiyDzNVFbwwJX44hOlRKC/mfwmFYBE07wJ5BAtuqQ/zojT7WNn6n9Eflb5EA7oNrUzuaTJZCg3T45mtq3mIVQ0csVO+PpzzcKtCRgcGcSpVkf6UC/iEcyAXCy+euVgAc/UzZM5PGXzLk= riad@Riads-MacBook-Pro.local"
    ];
  };

  home-manager.users.riad = { config, pkgs, ... }: {
    home.stateVersion = "25.05";

    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        history = {
          size = 10000;
          ignoreDups = true;
          ignoreSpace = true;
        };
        shellAliases = {
          ll = "ls -l";
          la = "ls -la";
          ".." = "cd ..";
          grep = "grep --color=auto";
          rebuild = "sudo nixos-rebuild switch --flake github:riadloukili/nixos-config#$CLOUD_PROVIDER-$(hostname)";
        };
        oh-my-zsh = {
          enable = true;
          theme = "powerlevel10k/powerlevel10k";
          plugins = [ "git" "sudo" "history" ];
        };
        plugins = [
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
        ];
        initExtra = ''
          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        '';
      };
      
      git = {
        enable = true;
        userName = "riad";
        userEmail = "me@riad.ca";
        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = true;
        };
      };
      
      neovim = {
        enable = true;
        defaultEditor = true;
        vimAlias = true;
        viAlias = true;
        extraConfig = ''
          set number
          set relativenumber
          set expandtab
          set tabstop=2
          set shiftwidth=2
          set smartindent
          set ignorecase
          set smartcase
          set hlsearch
          set incsearch
        '';
      };
      
      htop.enable = true;
    };

    home.packages = with pkgs; [
      curl
      wget
      tree
      unzip
      ripgrep
      fd
      bat
    ];

    home.file.".p10k.zsh".source = ../../dotfiles/riad/p10k.zsh;
  };
}