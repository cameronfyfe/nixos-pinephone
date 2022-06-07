{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mobile-nixos = {
      url = "github:samueldr-wip/mobile-nixos-wip/wip/pinephone-pro";
      flake = false;
    };
  };

  outputs = inputs @ { self, ... }:
    (inputs.flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-linux"
    ]
      (system:
        let

          pkgs = import inputs.nixpkgs {
            inherit system;
          };

        in
        rec {

          devShells = {
            qemu = pkgs.mkShell {
              nativeBuildInputs = with pkgs; [ cloud-utils curl envsubst gnumake qemu ];
              shellHook = ''
                cd qemu
              '';
            };

          };
        }))
    //
    {
      packages."aarch64-linux" = {
        nixos-pinephone-image =
          (import inputs.mobile-nixos {
            device = "pine64-pinephone";
          }).outputs.disk-image;
      };
      packages."aarch64-linux" = {
        nixos-pinephonepro-image =
          (import inputs.mobile-nixos {
            device = "pine64-pinephone";
          }).outputs.disk-image;
      };
    }
  ;
}
