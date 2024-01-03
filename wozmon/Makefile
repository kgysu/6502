SHELL=/bin/bash

build: wozmon.s
	vasm6502_oldstyle -Fbin -dotdir -wdc02 wozmon.s

install: build
	minipro -p AT28C256 -w a.out

verify:
	minipro -p AT28C256 -r read.bin
	hexdump -C read.bin

dump: a.out
	hexdump -C a.out

cleanup: a.out
	rm a.out
