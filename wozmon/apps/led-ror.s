
PORTA = $6001
DDRA = $6003

LVA = $3000     ; LED value

  .org $1000

reset:
  lda #%11111111  ; Set all pins on port A to output
  sta DDRA
  lda #0
  sta PORTA

led_loop:
  lda LVA
  ror
  sta PORTA       ; Toggle LED
  sta LVA
  jmp $FF00
