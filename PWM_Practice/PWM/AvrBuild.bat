@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\PWM\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\PWM\PWM.hex" -d "C:\AVR_PROJECT\PWM\PWM.obj" -e "C:\AVR_PROJECT\PWM\PWM.eep" -m "C:\AVR_PROJECT\PWM\PWM.map" "C:\AVR_PROJECT\PWM\PWM.asm"
