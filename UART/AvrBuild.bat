@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\UART\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\UART\UART.hex" -d "C:\AVR_PROJECT\UART\UART.obj" -e "C:\AVR_PROJECT\UART\UART.eep" -m "C:\AVR_PROJECT\UART\UART.map" "C:\AVR_PROJECT\UART\UART.asm"
