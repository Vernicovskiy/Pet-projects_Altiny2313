@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\IR_DECODER_addition\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\IR_DECODER_addition\IR_DECODER_addition.hex" -d "C:\AVR_PROJECT\IR_DECODER_addition\IR_DECODER_addition.obj" -e "C:\AVR_PROJECT\IR_DECODER_addition\IR_DECODER_addition.eep" -m "C:\AVR_PROJECT\IR_DECODER_addition\IR_DECODER_addition.map" "C:\AVR_PROJECT\IR_DECODER_addition\IR_DECODER_addition.asm"