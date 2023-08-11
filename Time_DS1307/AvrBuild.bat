@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Time_DS1307\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Time_DS1307\Time_DS1307.hex" -d "C:\AVR_PROJECT\Time_DS1307\Time_DS1307.obj" -e "C:\AVR_PROJECT\Time_DS1307\Time_DS1307.eep" -m "C:\AVR_PROJECT\Time_DS1307\Time_DS1307.map" "C:\AVR_PROJECT\Time_DS1307\Time_DS1307.asm"
