@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Unconditional_jump\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Unconditional_jump\Unconditional_jump.hex" -d "C:\AVR_PROJECT\Unconditional_jump\Unconditional_jump.obj" -e "C:\AVR_PROJECT\Unconditional_jump\Unconditional_jump.eep" -m "C:\AVR_PROJECT\Unconditional_jump\Unconditional_jump.map" "C:\AVR_PROJECT\Unconditional_jump\Unconditional_jump.asm"