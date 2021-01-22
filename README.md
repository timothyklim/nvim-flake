# Install

## Global installation for NixOS

/etc/nixos/configuration.nix:

```nix
{
# ...
  nixpkgs.overlays = [
    (import
      (fetchTarball {
        url = "https://github.com/TimothyKlim/nvim-flake/archive/11f4502fe38a2c79d648a0223d51b7b978589048.tar.gz";
        sha256 = "1lyxjapihfvivfdxsdshrsv7rgpg3q13xqg2c20bcplvw05p9av1";
      })).overlay
  ];
# ...
}
```
