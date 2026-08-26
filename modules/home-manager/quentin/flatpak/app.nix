{ lib, enableApp ? false }:

# Keys are defined unconditionally and only their values depend on
# `enableApp`, otherwise the module fixpoint forces `mx.services.flatpak.enable`
# while building the config attribute set, which is an infinite recursion.
appId:
{
  mx.services.flatpak.apps = lib.optionals enableApp [ appId ];
  mx.services.flatpak.removedApps = lib.optionals (!enableApp) [ appId ];
}
