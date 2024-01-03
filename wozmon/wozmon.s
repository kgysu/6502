PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
T1CL = $6004
T1CH = $6005
ACR = $600B
IFR = $600D
IER = $600E

ticks = $00
toggle_time = $04

LV1 = $3000     ; LED value 1
MSG = $3002     ; Message buffer LCD

E  = %01000000
RW = %00100000
RS = %00010000

    .org $8000

lcd_reset:
  ldx #$ff
  txs

  lda #%11111111 ; Set all pins on port B to output
  sta DDRB

  jsr lcd_init
  lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction

  ldx #$00
lcd_print:
  lda MSG,x
  beq halt
  jsr print_char
  inx
  jmp lcd_print

halt:
  jmp $ff00       ; Return to Wozmon

;message: .asciiz "Hello, world!"

lcd_wait:
  pha
  lda #%11110000  ; LCD data is input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read high nibble
  pha             ; and put on stack since it has the busy flag
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read low nibble
  pla             ; Get high nibble off stack
  and #%00001000
  bne lcdbusy

  lda #RW
  sta PORTB
  lda #%11111111  ; LCD data is output
  sta DDRB
  pla
  rts

lcd_init:
  lda #%00000010 ; Set 4-bit mode
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB
  rts

lcd_instruction:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr            ; Send high 4 bits
  sta PORTB
  ora #E         ; Set E bit to send instruction
  sta PORTB
  eor #E         ; Clear E bit
  sta PORTB
  pla
  and #%00001111 ; Send low 4 bits
  sta PORTB
  ora #E         ; Set E bit to send instruction
  sta PORTB
  eor #E         ; Clear E bit
  sta PORTB
  rts

print_char:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr             ; Send high 4 bits
  ora #RS         ; Set RS
  sta PORTB
  ora #E          ; Set E bit to send instruction
  sta PORTB
  eor #E          ; Clear E bit
  sta PORTB
  pla
  and #%00001111  ; Send low 4 bits
  ora #RS         ; Set RS
  sta PORTB
  ora #E          ; Set E bit to send instruction
  sta PORTB
  eor #E          ; Clear E bit
  sta PORTB
  rts


    .org $9000

led_reset:
  lda #%11111111  ; Set all pins on port A to output
  sta DDRA
  lda #0
  sta PORTA
  sta toggle_time
  jsr led_init_timer

led_loop:
  sec
  lda ticks
  sbc toggle_time
  cmp #25         ; Have 250ms elapsed?
  bcc led_loop
  lda LV1
  sta PORTA       ; Toggle LED
  inc
  sta LV1
  lda ticks
  sta toggle_time
  jmp led_loop

led_init_timer:
  lda #0
  sta ticks
  sta ticks + 1
  sta ticks + 2
  sta ticks + 3
  lda #%01000000
  sta ACR
  lda #$0e
  sta T1CL
  lda #$27
  sta T1CH
  lda #%11000000
  sta IER
  cli
  rts

irq:
  bit T1CL
  inc ticks
  bne end_irq
  inc ticks + 1
  bne end_irq
  inc ticks + 2
  bne end_irq
  inc ticks + 3
end_irq:
  rti

    .org $ff00

XAML  = $24                     ; Last "opened" location Low
XAMH  = $25                     ; Last "opened" location High
STL   = $26                     ; Store address Low
STH   = $27                     ; Store address High
L     = $28                     ; Hex value parsing Low
H     = $29                     ; Hex value parsing High
YSAV  = $2A                     ; Used to see if hex value is given
MODE  = $2B                     ; $00=XAM, $7F=STOR, $AE=BLOCK XAM

IN    = $0200                   ; Input buffer

ACIA_DATA   = $5000
ACIA_STATUS = $5001
ACIA_CMD    = $5002
ACIA_CTRL   = $5003

RESET:
    LDA #$1F                    ; 8-N-1, 19200 baud.
    STA ACIA_CTRL
    LDA #$0B                    ; No parity, no echo, no interrupts.
    STA ACIA_CMD
    LDA #$1B                    ; Begin with escape.

NOTCR:
    CMP #$08                    ; Backspace key?
    BEQ BACKSPACE               ; Yes.
    CMP #$1B                    ; ESC?
    BEQ ESCAPE                  ; Yes.
    INY                         ; Advance text index.
    BPL NEXTCHAR                ; Auto ESC if line longer than 127.

ESCAPE:
    LDA #$5C                    ; "\".
    JSR ECHO                    ; Output it.

GETLINE:
    LDA #$0D                    ; Send CR
    JSR ECHO

    LDY #$01                    ; Initialize text index.
BACKSPACE:
    DEY                         ; Back up text index.
    BMI GETLINE                 ; Beyond start of line, reinitialize.

NEXTCHAR:
    LDA ACIA_STATUS             ; Check status.
    AND #$08                    ; Key ready?
    BEQ NEXTCHAR                ; Loop until ready.
    LDA ACIA_DATA               ; Load character. B7 will be '0'.
    STA IN,Y                    ; Add to text buffer.
    JSR ECHO                    ; Display character.
    CMP #$0D                    ; CR?
    BNE NOTCR                   ; No.

    LDY #$FF                    ; Reset text index.
    LDA #$00                    ; For XAM mode.
    TAX                         ; X=0.
SETBLOCK:
    ASL
SETSTOR:
    ASL                         ; Leaves $7B if setting STOR mode.
    STA MODE                    ; $00 = XAM, $74 = STOR, $B8 = BLOK XAM.
BLSKIP:
    INY                         ; Advance text index.
NEXTITEM:
    LDA IN,Y                    ; Get character.
    CMP #$0D                    ; CR?
    BEQ GETLINE                 ; Yes, done this line.
    CMP #$2E                    ; "."?
    BCC BLSKIP                  ; Skip delimiter.
    BEQ SETBLOCK                ; Set BLOCK XAM mode.
    CMP #$3A                    ; ":"?
    BEQ SETSTOR                 ; Yes, set STOR mode.
    CMP #$52                    ; "R"?
    BEQ RUN                     ; Yes, run user program.
    STX L                       ; $00 -> L.
    STX H                       ;    and H.
    STY YSAV                    ; Save Y for comparison

NEXTHEX:
    LDA IN,Y                    ; Get character for hex test.
    EOR #$30                    ; Map digits to $0-9.
    CMP #$0A                    ; Digit?
    BCC DIG                     ; Yes.
    ADC #$88                    ; Map letter "A"-"F" to $FA-FF.
    CMP #$FA                    ; Hex letter?
    BCC NOTHEX                  ; No, character not hex.
DIG:
    ASL
    ASL                         ; Hex digit to MSD of A.
    ASL
    ASL

    LDX #$04                    ; Shift count.
HEXSHIFT:
    ASL                         ; Hex digit left, MSB to carry.
    ROL L                       ; Rotate into LSD.
    ROL H                       ; Rotate into MSD's.
    DEX                         ; Done 4 shifts?
    BNE HEXSHIFT                ; No, loop.
    INY                         ; Advance text index.
    BNE NEXTHEX                 ; Always taken. Check next character for hex.

NOTHEX:
    CPY YSAV                    ; Check if L, H empty (no hex digits).
    BEQ ESCAPE                  ; Yes, generate ESC sequence.

    BIT MODE                    ; Test MODE byte.
    BVC NOTSTOR                 ; B6=0 is STOR, 1 is XAM and BLOCK XAM.

    LDA L                       ; LSD's of hex data.
    STA (STL,X)                 ; Store current 'store index'.
    INC STL                     ; Increment store index.
    BNE NEXTITEM                ; Get next item (no carry).
    INC STH                     ; Add carry to 'store index' high order.
TONEXTITEM:
    JMP NEXTITEM                ; Get next command item.

RUN:
    JMP (XAML)                  ; Run at current XAM index.

NOTSTOR:
    BMI XAMNEXT                 ; B7 = 0 for XAM, 1 for BLOCK XAM.

    LDX #$02                    ; Byte count.
SETADR:
    LDA L-1,X                   ; Copy hex data to
    STA STL-1,X                 ;  'store index'.
    STA XAML-1,X                ; And to 'XAM index'.
    DEX                         ; Next of 2 bytes.
    BNE SETADR                  ; Loop unless X = 0.

NXTPRNT:
    BNE PRDATA                  ; NE means no address to print.
    LDA #$0D                    ; CR.
    JSR ECHO                    ; Output it.
    LDA XAMH                    ; 'Examine index' high-order byte.
    JSR PRBYTE                  ; Output it in hex format.
    LDA XAML                    ; Low-order 'examine index' byte.
    JSR PRBYTE                  ; Output it in hex format.
    LDA #$3A                    ; ":".
    JSR ECHO                    ; Output it.

PRDATA:
    LDA #$20                    ; Blank.
    JSR ECHO                    ; Output it.
    LDA (XAML,X)                ; Get data byte at 'examine index'.
    JSR PRBYTE                  ; Output it in hex format.
XAMNEXT:
    STX MODE                    ; 0 -> MODE (XAM mode).
    LDA XAML
    CMP L                       ; Compare 'examine index' to hex data.
    LDA XAMH
    SBC H
    BCS TONEXTITEM              ; Not less, so no more data to output.

    INC XAML
    BNE MOD8CHK                 ; Increment 'examine index'.
    INC XAMH

MOD8CHK:
    LDA XAML                    ; Check low-order 'examine index' byte
    AND #$07                    ; For MOD 8 = 0
    BPL NXTPRNT                 ; Always taken.

PRBYTE:
    PHA                         ; Save A for LSD.
    LSR
    LSR
    LSR                         ; MSD to LSD position.
    LSR
    JSR PRHEX                   ; Output hex digit.
    PLA                         ; Restore A.

PRHEX:
    AND #$0F                    ; Mask LSD for hex print.
    ORA #$30                    ; Add "0".
    CMP #$3A                    ; Digit?
    BCC ECHO                    ; Yes, output it.
    ADC #$06                    ; Add offset for letter.

ECHO:
    PHA                         ; Save A.
    STA ACIA_DATA               ; Output character.
    LDA #$FF                    ; Initialize delay loop.
TXDELAY:
    DEC                         ; Decrement A.
    BNE TXDELAY                 ; Until A gets to 0.
    PLA                         ; Restore A.
    RTS                         ; Return.

    .org $FFFA

    .word   $0F00               ; NMI vector
    .word   RESET               ; RESET vector
    .word   irq                 ; IRQ vector
