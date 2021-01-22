{
  description = "NVIM nightly flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    src = {
      url = "github:neovim/neovim/1607dd071fe1685cf42b0182b8d1d72152af2c40";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-compat, src }:
    let
      sources = with builtins; (fromJSON (readFile ./flake.lock)).nodes;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      nvim = import ./build.nix {
        inherit pkgs src;
      };
      mkApp = drv: {
        type = "app";
        program = "${drv.pname or drv.name}${drv.passthru.exePath}";
      };
    in
    rec {
      packages.${system}.nvim = nvim;
      defaultPackage.${system} = nvim;
      apps.${system}.nvim = mkApp { drv = nvim; };
      defaultApp.${system} = apps.nvim;
      legacyPackages.${system} = pkgs.extend overlay;
      nixosModule.nixpkgs.overlays = [ overlay ];
      overlay = final: prev: {
        nvim = nvim;
      };
    };
}
