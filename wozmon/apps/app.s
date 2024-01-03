PORTA = $6001
LV1 = $3000     ; LED value 1

  lda LV1
  sta PORTA
  inc
  sta LV1
  jmp $ff00
