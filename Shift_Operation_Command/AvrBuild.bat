@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Shift_Operation_Command\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Shift_Operation_Command\Shift_Operation_Command.hex" -d "C:\AVR_PROJECT\Shift_Operation_Command\Shift_Operation_Command.obj" -e "C:\AVR_PROJECT\Shift_Operation_Command\Shift_Operation_Command.eep" -m "C:\AVR_PROJECT\Shift_Operation_Command\Shift_Operation_Command.map" "C:\AVR_PROJECT\Shift_Operation_Command\Shift_Operation_Command.asm"
