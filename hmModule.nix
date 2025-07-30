{
  config,
  lib,
  ...
}: let
  inherit (builtins) concatStringsSep;
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.services.lsfg-vk;

  boolToStr = b:
    if b
    then "true"
    else "false";
  renderGame = game: ''
    [[game]]
    exe = "${game.exe}"
    multiplier = ${toString game.multiplier}
    flow_scale = ${toString game.flow_scale}
    performance_mode = ${boolToStr game.performance_mode}
    hdr_mode = ${boolToStr game.hdr_mode}
    experimental_present_mode = "${game.experimental_present_mode}"
  '';
  configText =
    ''
      version = 1

      [global]
      dll = "${cfg.global.dll}"
    ''
    + (concatStringsSep "\n\n" (map renderGame cfg.games));
in {
  options.services.lsfg-vk = {
    enable = mkEnableOption "lsfg-vk home-manager module to configure lsfg-vk";
    global.dll = mkOption {
      type = types.str;
      default = "$HOME/.local/share/Steam/steamapps/common/Lossless Scaling/Lossless.dll";
      description = "The path to the Lossless Scaling DLL";
    };
    games = mkOption {
      type = types.listOf (types.submodule {
        options = {
          exe = mkOption {
            type = types.str;
            description = "Name of the executable.";
          };
          multiplier = mkOption {
            type = types.int;
            description = "Scaling multiplier.";
          };
          flow_scale = mkOption {
            type = types.float;
            description = "Flow scale factor.";
          };
          performance_mode = mkOption {
            type = types.bool;
            default = true;
            description = "Enable performance mode.";
          };
          hdr_mode = mkOption {
            type = types.bool;
            default = false;
            description = "Enable HDR mode.";
          };
          experimental_present_mode = mkOption {
            type = types.enum ["mailbox" "fifo" "immediate"];
            description = "Experimental present mode.";
          };
        };
      });
      default = [];
      description = "List of game-specific configurations.";
    };
  };
  config = mkIf cfg.enable {
    xdg.configFile."lsfg-vk/conf.toml".text = configText;
  };
}
