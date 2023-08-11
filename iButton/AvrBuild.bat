@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\iButton\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\iButton\iButton.hex" -d "C:\AVR_PROJECT\iButton\iButton.obj" -e "C:\AVR_PROJECT\iButton\iButton.eep" -m "C:\AVR_PROJECT\iButton\iButton.map" "C:\AVR_PROJECT\iButton\iButton.asm"
