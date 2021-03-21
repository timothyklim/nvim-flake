{
  description = "NVIM nightly flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    src = {
      url = "github:neovim/neovim/e5bef5974e900001cb6ed302b39a6f5ddf48d9a4";
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
      derivation = { inherit nvim; };
    in
    rec {
      packages.${system} = derivation;
      defaultPackage.${system} = nvim;
      apps.${system}.nvim = mkApp { drv = nvim; };
      defaultApp.${system} = apps.nvim;
      legacyPackages.${system} = pkgs.extend overlay;
      nixosModule.nixpkgs.overlays = [ overlay ];
      overlay = final: prev: derivation;
      devShell.${system} = pkgs.mkShell {
        name = "nvim-env";
        buildInputs = [ nvim ];
      };
    };
}
