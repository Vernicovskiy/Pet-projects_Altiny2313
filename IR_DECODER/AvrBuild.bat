@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\IR_DECODER\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\IR_DECODER\IR_DECODER.hex" -d "C:\AVR_PROJECT\IR_DECODER\IR_DECODER.obj" -e "C:\AVR_PROJECT\IR_DECODER\IR_DECODER.eep" -m "C:\AVR_PROJECT\IR_DECODER\IR_DECODER.map" "C:\AVR_PROJECT\IR_DECODER\IR_DECODER.asm"
