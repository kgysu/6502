### Build

run:

```bash
vasm6502_oldstyle -Fbin -dotdir -wdc02 hello-world-ram.s

hexdump -e '"1%03_ax: " 16/1 "%02X " "\n"' a.out | awk '{print toupper($0)}'

hexdump -e '"1%03_ax: " 16/1 "%02X " "\n"' a.out | awk '{print toupper($0)}' > a.raw
```


## ROM

ROM Apps

### LCD Message

Run at: `$8000`

Message Value in Memory: `$3002`


### LED blink


