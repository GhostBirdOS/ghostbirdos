all:
	nasm boot.asm -o boot.bin
	cp  boot.bin os.img
	dd if=/dev/zero of=os.img seek=2 count=2879	
	cp os.img ../
