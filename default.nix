{ ... }:
let
  flake-compat = import
    (
      let
        lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      in
      fetchTarball {
        url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
        sha256 = lock.nodes.flake-compat.locked.narHash;
      }
    );
  flake = flake-compat { src = ./.; };
  maybe = c:
    let result = builtins.tryEval c; in if result.success then result.value else { };
in
{ inherit flake-compat flake; self = flake.defaultNix; }
// maybe flake.defaultNix
  // maybe flake.defaultNix.defaultPackage.${builtins.currentSystem}
