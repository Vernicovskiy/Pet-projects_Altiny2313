@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Project_5\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Project_5\Project_5.hex" -d "C:\AVR_PROJECT\Project_5\Project_5.obj" -e "C:\AVR_PROJECT\Project_5\Project_5.eep" -m "C:\AVR_PROJECT\Project_5\Project_5.map" "C:\AVR_PROJECT\Project_5\Project_5.asm"
