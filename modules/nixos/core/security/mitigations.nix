{
  lib,
  config,
  ...
}:
{
  options.mx.security.mitigations = {
    enable = lib.mkOption {
      description = "Enable kernel CVE mitigations";
      type = lib.types.bool;
      default = true;
    };
    blacklistDirtyFrag = lib.mkOption {
      description = "Blacklist esp4/esp6 (CVE-2026-43284) and rxrpc (CVE-2026-43500).";
      type = lib.types.bool;
      default = true;
    };
    blacklistCopyFail = lib.mkOption {
      description = "Blacklist algif_aead (CVE-2026-31431).";
      type = lib.types.bool;
      default = true;
    };
    blacklistFragnesia = lib.mkOption {
      description = "Blacklist ipcomp4/ipcomp6 (CVE-2026-46300).";
      type = lib.types.bool;
      default = true;
    };
    mitigateSshKeysignPwn = lib.mkOption {
      description = "Harden ptrace_scope to 2 against CVE-2026-46333.";
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf config.mx.security.mitigations.enable {
    boot.blacklistedKernelModules =
      lib.optionals config.mx.security.mitigations.blacklistDirtyFrag [
        "esp4"
        "esp6"
        "rxrpc"
      ]
      ++ lib.optionals config.mx.security.mitigations.blacklistCopyFail [
        "algif_aead"
      ]
      ++ lib.optionals config.mx.security.mitigations.blacklistFragnesia [
        "ipcomp4"
        "ipcomp6"
      ];

    boot.kernel.sysctl = lib.mkIf config.mx.security.mitigations.mitigateSshKeysignPwn {
      "kernel.yama.ptrace_scope" = 2;
    };

    assertions = [
      {
        assertion =
          config.mx.security.mitigations.blacklistDirtyFrag
          -> !(builtins.elem "esp4" config.boot.kernelModules
            || builtins.elem "esp6" config.boot.kernelModules
            || builtins.elem "rxrpc" config.boot.kernelModules);
        message = ''
          mx.security.mitigations.blacklistDirtyFrag = true but a vulnerable
          module (esp4/esp6/rxrpc) is forced via boot.kernelModules.
          Explicitly disable blacklistDirtyFrag if you need it.
        '';
      }
      {
        assertion =
          config.mx.security.mitigations.blacklistFragnesia
          -> !(builtins.elem "ipcomp4" config.boot.kernelModules
            || builtins.elem "ipcomp6" config.boot.kernelModules);
        message = ''
          mx.security.mitigations.blacklistFragnesia = true but a vulnerable
          module (ipcomp4/ipcomp6) is forced via boot.kernelModules.
          Explicitly disable blacklistFragnesia if you need it.
        '';
      }
    ];
  };
}
