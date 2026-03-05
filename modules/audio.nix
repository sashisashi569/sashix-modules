# Audio configuration
# - PipeWire with ALSA and PulseAudio compatibility
# - RealtimeKit for low-latency audio
{ lib, config, ... }:

{
  options.sashix.audio = {
    enable = lib.mkEnableOption "audio via PipeWire";
  };

  config = lib.mkIf config.sashix.audio.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable      = true;

    services.pipewire = {
      enable           = true;
      alsa.enable      = true;
      alsa.support32Bit = true;
      pulse.enable     = true;
    };
  };
}
