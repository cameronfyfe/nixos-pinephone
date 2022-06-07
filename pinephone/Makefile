.PHONY: default
default: images

.PHONY: build
build:
	nix build -L

.PHONY: fmt
fmt:
	nixpkgs-fmt *.nix

jumpdriveXz := github.com/dreemurrs-embedded/Jumpdrive/releases/download/0.8/pine64-pinephone.img.xz
jumpdrive := $(basename $(jumpdriveXz))

towbootTarXz := github.com/Tow-Boot/Tow-Boot/releases/download/release-2021.10-004/pine64-pinephoneA64-2021.10-004.tar.xz
towboot := $(basename $(basename $(towbootTarXz)))
towbootInstaller := $(towboot)/mmcboot.installer.img
$(towbootInstaller): $(towboot)

mobianInstallerGz := images.mobian-project.org/pinephone/installer/weekly/mobian-installer-pinephone-phosh-20220529.img.gz
mobianInstaller := $(basename $(mobianInstallerGz))

nixos := nixos-pinephone-image/mobile-nixos.img
nixos-pinephone-image:
	NIXPKGS_ALLOW_UNFREE=1 \
	nix build .#nixos-pinephone-image -o $@ls

$(nixos): nixos-pinephone-image

$(jumpdriveXz) $(towbootTarXz) $(mobianInstallerGz):
	mkdir -p $(dir $@)
	curl -L -o $@ https://$@

%: %.xz
	unxz --keep $<

%: %.gz
	gzip -d --keep $<

%: %.tar
	tar -xf $< -C $(dir $@) && touch $@

%: %.tar.xz
	$(MAKE) $@.tar
	$(MAKE) $@

images := \
jumpdrive \
towboot-installer \
mobian-installer \
nixos \

imageTargets := $(addprefix image-, $(images))
flashTargets := $(addprefix flash-, $(images))

.PHONY: $(imageTargets) $(flashTargets)
image-jumpdrive flash-jumpdrive: $(jumpdrive)
image-towboot-installer flash-towboot-installer: $(towbootInstaller)
image-mobian-installer flash-mobian-installer: $(mobianInstaller)
image-nixos flash-nixos: $(nixos)

$(flashTargets):
	dd \
		if=$< \
		of=/dev/$(BD) \
		bs=64k \
		status=progress
	sync

.PHONY: format
format:
	dd \
		if=/dev/zero \
		of=/dev/$(BD) \
		bs=4096 \
		status=progress
	sync

.PHONY: safely-remove
safely-remove:
	udisksctl power-off --block-device /dev/$(BD)

test:
	dd \
		if=result/mobile-nixos.img \
		of=/dev/sdb \
		bs=64k \
		status=progress
	sync
	udisksctl power-off --block-device /dev/sdbnix 