# Install

## Global installation for NixOS

/etc/nixos/configuration.nix:

```nix
let
  nvim = import (fetchTarball {
    url = "https://github.com/TimothyKlim/nvim-flake/archive/1a754c846419fa0a9128d8755fffb9419103c11c.tar.gz";
    sha256 = "sha256:0y4qcy313vsa9qgx8cizxn2vw72cgl05ynna1gyz0m8n13nzw7kc";
  }) {};
# ...
in
{
# ...
  environment.systemPackages = [
    nvim
    # ...
  ];
# ...
}
```

