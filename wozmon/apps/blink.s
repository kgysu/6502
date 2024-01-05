
PORTA = $6001
DDRA = $6003
T1CL = $6004
T1CH = $6005
ACR = $600B
IER = $600E

ticks = $00
toggle_time = $04

LVA = $3000     ; LED value

  .org $1000

reset:
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
  lda LVA
  ror
  sta PORTA       ; Toggle LED
  ;sta LVA
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
