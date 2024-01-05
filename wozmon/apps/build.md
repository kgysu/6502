### Build

run:

```bash
vasm6502_oldstyle -Fbin -dotdir -wdc02 message.s

hexdump -e '"1%03_ax: " 16/1 "%02X " "\n"' a.out | awk '{print toupper($0)}'

hexdump -e '"1%03_ax: " 16/1 "%02X " "\n"' a.out | awk '{print toupper($0)}' > a.raw
```


## ROM

ROM predefined Apps

### LCD Message

Run init at: `$8000`

Message Value in Memory: `$3002`

Clear Display at: `$8D00`

Print message at: `$8F00`


### LED blink


