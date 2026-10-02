# Audio: pipewire with ALSA and PulseAudio compatibility.
{
  flake.modules.nixos."desktop/audio" = {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
