# `install-<host>` on a host's live ISO: runs the host's disko script (asks for
# confirmation, wipes the declared disks) then nixos-install from the closure
# that is already on the image — no network needed.
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
      name = config.my.installer.name;
      script = pkgs.writeShellApplication {
        name = "install-${name}";
        runtimeInputs = [
          pkgs.util-linux
          pkgs.nixos-install-tools
        ];
        text = ''
          if [ "$(id -u)" -ne 0 ]; then exec sudo "$0" "$@"; fi
          echo "== install ${name} =="
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
          echo "Installed. Reboot, then enrol secrets with 'just sops-add-host ${name} <ip>'."
        '';
      };
    in
    {
      options.my.installer.target = {
        toplevel = lib.mkOption { type = lib.types.package; };
        diskoScript = lib.mkOption { type = lib.types.package; };
        disks = lib.mkOption { type = lib.types.listOf lib.types.str; };
      };

      config = {
        environment.systemPackages = [ script ];
        isoImage.storeContents = [ cfg.toplevel ];
        services.getty.helpLine = lib.mkAfter ''

          Run `install-${name}` to install ${name} onto ${lib.concatStringsSep ", " cfg.disks} (--dry-run to preview).
        '';
      };
    };
}
