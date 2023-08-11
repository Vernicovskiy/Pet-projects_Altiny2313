@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Encoder\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Encoder\Encoder.hex" -d "C:\AVR_PROJECT\Encoder\Encoder.obj" -e "C:\AVR_PROJECT\Encoder\Encoder.eep" -m "C:\AVR_PROJECT\Encoder\Encoder.map" "C:\AVR_PROJECT\Encoder\Encoder.asm"
