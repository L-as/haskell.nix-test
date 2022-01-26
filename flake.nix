{
  description = "plutarch";

  inputs.haskell-nix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskell-nix/nixpkgs-unstable";

  outputs = inputs@{ self, nixpkgs, haskell-nix, ... }:
    let
      supportedSystems = with nixpkgs.lib.systems.supported; tier1 ++ tier2 ++ tier3;

      perSystem = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = system: import nixpkgs { inherit system; overlays = [ haskell-nix.overlay ]; inherit (haskell-nix) config; };

      compiler-nix-name = "ghc921";

      projectFor = system:
        let pkgs = nixpkgsFor system; in
        (nixpkgsFor system).haskell-nix.cabalProject' {
          src = ./.;
          inherit compiler-nix-name;
          shell.exactDeps = true;
          shell.tools.cabal = {};
        };
    in
    {
      project = perSystem projectFor;

      defaultPackage = perSystem (system: (self.project.${system}.flake {}).packages."mylib:lib:mylib");
      devShell = perSystem (system: (self.project.${system}.flake {}).devShell);
    };
}
