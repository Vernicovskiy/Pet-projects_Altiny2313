@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Keyboard\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Keyboard\Keyboard.hex" -d "C:\AVR_PROJECT\Keyboard\Keyboard.obj" -e "C:\AVR_PROJECT\Keyboard\Keyboard.eep" -m "C:\AVR_PROJECT\Keyboard\Keyboard.map" "C:\AVR_PROJECT\Keyboard\Keyboard.asm"
