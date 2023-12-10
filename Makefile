all: flp
	qemu-system-x86_64 -hda boot.flp

flp:
	nasm boot.asm -f bin -o boot.bin
	dd status=noxfer conv=notrunc if=boot.bin of=boot.flp

clean:
	rm -f *.bin *.img *.flp *.iso
