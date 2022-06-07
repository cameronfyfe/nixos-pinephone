{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mobile-nixos = {
      url = "github:samueldr-wip/mobile-nixos-wip/wip/pinephone-pro";
      flake = false;
    };
    nixos-configs.url = "gitlab:cameronfyfe/nixos-configs";
  };

  outputs = inputs @ { self, ... }: {

    devShells."x86_64-linux" = {
      qemu = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [ cloud-utils curl envsubst gnumake qemu ];
        shellHook = ''
          cd qemu
        '';
      };
    };

    packages."aarch64-linux" = {
      nixos-pinephone-image =
        (import inputs.mobile-nixos {
          device = "pine64-pinephone";
        }).outputs.disk-image;
      nixos-pinephone-pro-image =
        (import inputs.mobile-nixos {
          device = "pine64-pinephonepro";
          configuration = { ... }: {
            imports = map (d: "${inputs.nixos-configs}/phone/${d}") [
              "apps"
              "home"
              "system"
              "users"
              "window-manager"
            ];
          };
        }).outputs.disk-image;
    };

  };
}
