qemu-system-x86_64 \
	-m 4G \
	-boot d \
	-display cocoa \
	-machine type=q35,accel=hvf \
	-smp 2 \
	-drive file=archlinux-2021.01.01.qcow2,media=disk,if=virtio \
	-cdrom /Users/emiliko/documents/safe/arch_vm/archlinux-2021.01.01-x86_64.iso
