@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Project_11\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Project_11\Project_11.hex" -d "C:\AVR_PROJECT\Project_11\Project_11.obj" -e "C:\AVR_PROJECT\Project_11\Project_11.eep" -m "C:\AVR_PROJECT\Project_11\Project_11.map" "C:\AVR_PROJECT\Project_11\Project_11.asm"
