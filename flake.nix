{
  description = "Kassa 2";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/4aa7aa0cf13946b7beb29844e02d0593489d5c7d"; # 26.11 before git-pages services issue

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bart-pkgs = {
      url = "git+https://git.bartoostveen.nl/bart/nix-packages.git";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      treefmt-nix,
      self,
      ...
    }@inputs:
    {
      # for `nix fmt`
      formatter.x86_64-linux =
        (treefmt-nix.lib.evalModule nixpkgs.outputs.legacyPackages.x86_64-linux ./base/treefmt.nix)
        .config.build.wrapper;
      # for `nix flake check`
      checks.x86_64-linux.formatting = (treefmt-nix.lib.evalModule nixpkgs.outputs.legacyPackages.x86_64-linux ./base/treefmt.nix).config.build.check self;

      nixosConfigurations."kassa2" = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/kassa2.nix
          ./hosts/hardware-configuration-kassa2.nix
          { nixpkgs.overlays = [ inputs.bart-pkgs.overlays.default ]; }
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };
}
