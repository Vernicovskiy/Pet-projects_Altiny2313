@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Project_9\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Project_9\Project_9.hex" -d "C:\AVR_PROJECT\Project_9\Project_9.obj" -e "C:\AVR_PROJECT\Project_9\Project_9.eep" -m "C:\AVR_PROJECT\Project_9\Project_9.map" "C:\AVR_PROJECT\Project_9\Project_9.asm"
