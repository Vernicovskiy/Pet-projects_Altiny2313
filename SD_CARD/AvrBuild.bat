@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\SD_CARD\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\SD_CARD\SD_CARD.hex" -d "C:\AVR_PROJECT\SD_CARD\SD_CARD.obj" -e "C:\AVR_PROJECT\SD_CARD\SD_CARD.eep" -m "C:\AVR_PROJECT\SD_CARD\SD_CARD.map" "C:\AVR_PROJECT\SD_CARD\SD_CARD.asm"
