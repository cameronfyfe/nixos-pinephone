images := nixos-pinephone.img nixos-pinephone-pro.img

.PHONY: default
default: $(images)

$(images): %.img:
	nix build .\#$*-image --impure -L -o $@
