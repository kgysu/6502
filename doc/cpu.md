# CPU Address layout

This table shows the address layout for the 6502 CPU.


| Hardware | A15 | A14 | A13 | A12 | A11 | A10 | A9 | A8 | A7 | A6 | A5 | A4 | A3 | A2 | A1 | A0 |
|----------|-----|-----|-----|-----|-----|-----|----|----|----|----|----|----|----|----|----|----|
| RAM      | 0   | 0   | x   | x   | x   | x   | x  | x  | x  | x  | x  | x  | x  | x  | x  | x  |
| ACIA     | 0   | 1   | 0   | 1   |     |     |    |    |    |    |    |    |    |    | x  | x  |
| VIA      | 0   | 1   | 1   | 0   |     |     |    |    |    |    |    |    | x  | x  | x  | x  |
| unusable | 0   | 1   | 1   | 1   |     |     |    |    |    |    |    |    |    |    |    |    |
| ROM      | 1   | x   | x   | x   | x   | x   | x  | x  | x  | x  | x  | x  | x  | x  | x  | x  |



| Hardware | Low    | High   |
|----------|--------|--------|
| RAM      | 0x0000 | 0x3FFF |
| ACIA     | 0x5000 | 0x5003 |
| VIA      | 0x6000 | 0x600F |
| unusable | 0x7000 | 0x7FFF |
| ROM      | 0x8000 | 0xFFFF |


