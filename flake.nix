{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.home-manager.url = github:nix-community/home-manager;
  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.agenix.url = "github:ryantm/agenix";
  inputs.hyprland.url = "github:hyprwm/Hyprland";

  outputs = { self, nixpkgs, home-manager, deploy-rs, agenix, hyprland, ... }@attrs: {
    nixosConfigurations."linc" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./configuration.nix home-manager.nixosModules.home-manager  ];
    };
    deploy.nodes.linc = {
      hostname = "linc.fritz.box";
      fastConnection = true;
      profiles = {
        system = {
          sshUser = "root";
          path =
            deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."linc";
          user = "root";
        };
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

  };
}
