@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Macros_and_Lib\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Macros_and_Lib\Macros_and_Lib.hex" -d "C:\AVR_PROJECT\Macros_and_Lib\Macros_and_Lib.obj" -e "C:\AVR_PROJECT\Macros_and_Lib\Macros_and_Lib.eep" -m "C:\AVR_PROJECT\Macros_and_Lib\Macros_and_Lib.map" "C:\AVR_PROJECT\Macros_and_Lib\Macros_and_Lib.asm"
