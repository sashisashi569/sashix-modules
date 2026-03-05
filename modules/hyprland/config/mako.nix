# home-manager: services.mako
{ ... }:

{
  services.mako = {
    enable   = true;
    settings = {
      anchor            = "top-right";
      "default-timeout" = 5000;
      "border-radius"   = 8;
      "max-visible"     = 5;
    };
  };
}
