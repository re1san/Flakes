{ system, self, nixpkgs, inputs, user, ... }:

let
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true; # Allow proprietary software
  };

  lib = nixpkgs.lib;
in
{
  hana = lib.nixosSystem {
    # Hana Host = MSI Stealth 14 Studio Laptop
    inherit system;
    specialArgs = { inherit inputs user; };
    modules = [
      ./hana/wayland
      # ./hana/x11 
    ] ++ [
      ./system.nix
    ] ++ [
      inputs.hyprland.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit user; };
          users.${user} = {
            imports = [
              (import ./hana/wayland/home.nix)
              # (import ./hana/x11/home.nix)
            ] ++ [
              inputs.hyprland.homeManagerModules.default
            ];
          };
        };
        nixpkgs = {
          overlays =
            (import ../overlays)
              ++ [
              self.overlays.default
              inputs.picom.overlays.default
            ];
        };
      }
    ];
  };

}
