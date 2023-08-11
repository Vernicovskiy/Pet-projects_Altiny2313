@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\T0_Match_Reset\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\T0_Match_Reset\T0_Match_Reset.hex" -d "C:\AVR_PROJECT\T0_Match_Reset\T0_Match_Reset.obj" -e "C:\AVR_PROJECT\T0_Match_Reset\T0_Match_Reset.eep" -m "C:\AVR_PROJECT\T0_Match_Reset\T0_Match_Reset.map" "C:\AVR_PROJECT\T0_Match_Reset\T0_Match_Reset.asm"
