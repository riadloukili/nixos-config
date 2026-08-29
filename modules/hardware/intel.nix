# Intel CPU + integrated GPU.
{
  flake.modules.nixos.hardware-intel =
    { inputs, pkgs, ... }:
    {
      imports = with inputs.nixos-hardware.nixosModules; [
        common-cpu-intel
        common-gpu-intel
      ];
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          intel-compute-runtime
        ];
      };
      services.thermald.enable = true;
    };
}
