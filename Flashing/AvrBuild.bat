@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Flashing\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Flashing\Flashing.hex" -d "C:\AVR_PROJECT\Flashing\Flashing.obj" -e "C:\AVR_PROJECT\Flashing\Flashing.eep" -m "C:\AVR_PROJECT\Flashing\Flashing.map" "C:\AVR_PROJECT\Flashing\Flashing.asm"
