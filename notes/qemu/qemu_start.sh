qemu-system-x86_64 \
	-m 4G \
	-smp 6 \
	-boot d \
	-display cocoa \
	-vga std \
	-serial stdio \
	-machine type=q35,accel=hvf \
	-drive file=archlinux-2021.01.01.qcow2,media=disk,if=virtio \
	-nic user,hostfwd=tcp::10022-:22
    #-net tap,script=/Users/emiliko/documents/safe/arch_vm/tap-up,downscript=/Users/emiliko/documents/safe/arch_vm/tap-down
    #-net nic,model=virtio,macaddr=54:54:00:55:55:55 \


