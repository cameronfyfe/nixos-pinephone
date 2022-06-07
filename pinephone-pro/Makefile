

towbootTarXz := github.com/Tow-Boot/Tow-Boot/releases/download/release-2021.10-004/pine64-pinephonePro-2021.10-004.tar.xz
towboot := $(basename $(basename $(towbootTarXz)))
towbootInstaller := $(towboot)/spi.installer.img
$(towbootInstaller): $(towboot)

mobianInstallerGz := images.mobian-project.org/pinephone/installer/weekly/mobian-installer-pinephone-phosh-20220529.img.gz
mobianInstaller := $(basename $(mobianInstallerGz))

$(towbootTarXz) $(mobianInstallerGz):
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
towboot-installer \
mobian-installer \

imageTargets := $(addprefix image-, $(images))
flashTargets := $(addprefix flash-, $(images))

.PHONY: $(imageTargets) $(flashTargets)
image-towboot-installer flash-towboot-installer: $(towbootInstaller)
image-mobian-installer flash-mobian-installer: $(mobianInstaller)

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
