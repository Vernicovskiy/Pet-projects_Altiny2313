@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\AVR_SIM\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\AVR_SIM\AVR_SIM.hex" -d "C:\AVR_PROJECT\AVR_SIM\AVR_SIM.obj" -e "C:\AVR_PROJECT\AVR_SIM\AVR_SIM_obj.eep" -m "C:\AVR_PROJECT\AVR_SIM\AVR_SIM_obj.map" "C:\AVR_PROJECT\AVR_SIM\AVR_SIM.asm"
