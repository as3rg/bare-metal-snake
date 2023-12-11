all: flp
	qemu-system-x86_64 -hda boot.flp

flp:
	nasm boot.asm -f bin -o boot.bin
	dd status=noxfer conv=notrunc if=boot.bin of=boot.flp

flush: flp
	if [ -w "/dev/$(DISK)" ]; then \
		dd if=boot.flp of=/dev/$(DISK); \
		sync; \
	else \
		echo "can't write to /dev/$(DISK)"; \
	fi

clean:
	rm -f *.bin *.img *.flp *.iso
