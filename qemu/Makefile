.PHONY: shell
shell:
	cd .. && nix develop .#qemu

SSH_KEY ?= "$(shell cat $(shell ls ~/.ssh/*.pub | head -1))"

ubuntu-16.04-server-cloudimg-arm64-uefi1.img:
	curl -L -o $@ https://cloud-images.ubuntu.com/releases/16.04/release/$@
	qemu-img resize $@ +20G

QEMU_EFI.fd:
	curl -L -o $@ https://releases.linaro.org/components/kernel/uefi-linaro/latest/release/qemu64/$@

flash0.img: QEMU_EFI.fd
	dd if=/dev/zero of=$@ bs=1M count=64
	dd if=$< of=$@ conv=notrunc

flash1.img:
	dd if=/dev/zero of=$@ bs=1M count=64

cloud.img: cloud.txt
	cloud-localds --disk-format qcow2 $@ $<

cloud.txt: cloud.txt.template
	SSH_KEY=$(SSH_KEY) envsubst < $< > $@ 

.PHONY: launch
launch: flash0.img flash1.img cloud.img ubuntu-16.04-server-cloudimg-arm64-uefi1.img
	qemu-system-aarch64 \
		-m 4096 \
		-smp 2 \
		-cpu cortex-a53 \
		-M virt \
		-nographic \
		-pflash flash0.img \
		-pflash flash1.img \
		-drive if=none,file=ubuntu-16.04-server-cloudimg-arm64-uefi1.img,id=hd0 \
		-device virtio-blk-device,drive=hd0 \
		-drive if=none,id=cloud,file=cloud.img \
		-device virtio-blk-device,drive=cloud \
		-device virtio-net-device,netdev=user0 \
		-netdev user,id=user0,hostfwd=tcp::2222-:22 \
	;

.PHONY: login
login:
	ssh -p 2222 arm-dev@localhost
