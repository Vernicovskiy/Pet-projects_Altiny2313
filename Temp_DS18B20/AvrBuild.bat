@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Temp_DS18B20\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Temp_DS18B20\Temp_DS18B20.hex" -d "C:\AVR_PROJECT\Temp_DS18B20\Temp_DS18B20.obj" -e "C:\AVR_PROJECT\Temp_DS18B20\Temp_DS18B20.eep" -m "C:\AVR_PROJECT\Temp_DS18B20\Temp_DS18B20.map" "C:\AVR_PROJECT\Temp_DS18B20\Temp_DS18B20.asm"
