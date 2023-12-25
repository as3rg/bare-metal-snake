qemu: flp
	qemu-system-x86_64 -hda boot.bin

flp:
	nasm boot.asm -f bin -o boot.bin

flush: flp
	if [ -w "/dev/$(DISK)" ]; then \
		dd if=boot.bin of=/dev/$(DISK); \
		sync; \
	else \
		echo "can't write to /dev/$(DISK)"; \
	fi

clean:
	rm -f *.bin *.img *.flp *.iso *.elf
