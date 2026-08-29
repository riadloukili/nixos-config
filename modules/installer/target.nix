# Adds `install-<host>` to a host's live ISO: wipes the disks declared in the
# host's disko config, then installs the host closure that is already on the
# image — no network needed. The disko destroy step asks for confirmation.
{
  flake.modules.nixos.installer-target =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.installer.target;
      script = pkgs.writeShellApplication {
        name = "install-${cfg.name}";
        runtimeInputs = [
          pkgs.util-linux
          pkgs.nixos-install-tools
        ];
        text = ''
          if [ "$(id -u)" -ne 0 ]; then exec sudo "$0" "$@"; fi
          echo "== install ${cfg.name} =="
          echo "Disks that will be WIPED: ${lib.concatStringsSep " " cfg.disks}"
          echo
          lsblk -o NAME,SIZE,MODEL,MOUNTPOINTS
          echo
          if [ "''${1:-}" = "--dry-run" ]; then
            echo "dry run: would run ${cfg.diskoScript} then nixos-install --system ${cfg.toplevel}"
            exit 0
          fi
          ${cfg.diskoScript}
          nixos-install --system ${cfg.toplevel} --root /mnt --no-root-passwd --no-channel-copy
          echo
          echo "Installed. Next: reboot, then enrol secrets with 'just sops-add-host ${cfg.name} <ip>'."
        '';
      };
    in
    {
      options.my.installer.target = {
        name = lib.mkOption { type = lib.types.str; };
        toplevel = lib.mkOption { type = lib.types.package; };
        diskoScript = lib.mkOption { type = lib.types.package; };
        disks = lib.mkOption { type = lib.types.listOf lib.types.str; };
      };

      config = {
        environment.systemPackages = [ script ];
        # Ship the target closure on the image so the install is offline.
        isoImage.storeContents = [ cfg.toplevel ];
        services.getty.helpLine = lib.mkAfter ''

          Run `install-${cfg.name}` to install ${cfg.name} onto ${lib.concatStringsSep ", " cfg.disks} (--dry-run to preview).
        '';
      };
    };
}
