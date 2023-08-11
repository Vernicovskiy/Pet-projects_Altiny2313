@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Project_2\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Project_2\Project_2.hex" -d "C:\AVR_PROJECT\Project_2\Project_2.obj" -e "C:\AVR_PROJECT\Project_2\Project_2.eep" -m "C:\AVR_PROJECT\Project_2\Project_2.map" "C:\AVR_PROJECT\Project_2\Project_2.asm"
