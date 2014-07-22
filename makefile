all:
	cd Boot && make 
	cd Kernel && make 
	sudo mount -o loop os.img /mnt
	sudo cp KERNEL  /mnt
	sudo umount /mnt
	

run:
	qemu -fda os.img
