SHELL=/bin/bash

build: rs232.s
	vasm6502_oldstyle -Fbin -dotdir -wdc02 rs232.s

install: build
	minipro -p AT28C256 -w a.out

verify:
	minipro -p AT28C256 -r read.bin
	hexdump -C read.bin

dump: a.out
	hexdump -C a.out

cleanup: a.out
	rm a.out
