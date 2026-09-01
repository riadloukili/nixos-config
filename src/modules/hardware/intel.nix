# Intel CPU + integrated GPU. nixos-hardware's intel modules bring the GPU
# stack (i915, intel-media-driver, compute runtime, VPL); this adds thermald
# and pins the VA-API driver to the modern one (Gen12+ needs no legacy driver).
{ inputs, ... }:
{
  flake.modules.nixos."hardware/intel" = {
    imports = [ inputs.nixos-hardware.nixosModules.common-cpu-intel ]; # also pulls common-gpu-intel
    hardware.graphics.enable = true;
    hardware.intelgpu.vaapiDriver = "intel-media-driver";
    services.thermald.enable = true;
  };
}
