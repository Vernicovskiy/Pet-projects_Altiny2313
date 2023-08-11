@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Project_8\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Project_8\Project_8.hex" -d "C:\AVR_PROJECT\Project_8\Project_8.obj" -e "C:\AVR_PROJECT\Project_8\Project_8.eep" -m "C:\AVR_PROJECT\Project_8\Project_8.map" "C:\AVR_PROJECT\Project_8\Project_8.asm"
