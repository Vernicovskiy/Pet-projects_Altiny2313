@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Project_4\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Project_4\Project_4.hex" -d "C:\AVR_PROJECT\Project_4\Project_4.obj" -e "C:\AVR_PROJECT\Project_4\Project_4.eep" -m "C:\AVR_PROJECT\Project_4\Project_4.map" "C:\AVR_PROJECT\Project_4\Project_4.asm"
