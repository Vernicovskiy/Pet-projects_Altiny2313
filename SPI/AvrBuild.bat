@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\SPI\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\SPI\SPI.hex" -d "C:\AVR_PROJECT\SPI\SPI.obj" -e "C:\AVR_PROJECT\SPI\SPI.eep" -m "C:\AVR_PROJECT\SPI\SPI.map" "C:\AVR_PROJECT\SPI\SPI.asm"
