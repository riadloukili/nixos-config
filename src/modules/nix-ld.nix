# A library path for unpackaged, dynamically linked binaries (nix.dev's nix-ld
# option). Mason installs generic-linux prebuilts into ~/.local/share/nvim, and
# without this they die on the stub loader: marksman, stylua and
# lua-language-server all do. Prefer a nixpkgs package when one exists —
# tree-sitter is in users/riad/home.nix for exactly that reason.
{
  flake.modules.nixos."nix-ld" =
    { pkgs, ... }:
    {
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc # libstdc++: lua-language-server, marksman
          zlib
          openssl
          icu # marksman (.NET)
          curl
        ];
      };
    };
}
