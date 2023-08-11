@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\AVR_PROJECT\Watchdog_Timer\labels.tmp" -fI -W+ie -C V2 -o "C:\AVR_PROJECT\Watchdog_Timer\Watchdog_Timer.hex" -d "C:\AVR_PROJECT\Watchdog_Timer\Watchdog_Timer.obj" -e "C:\AVR_PROJECT\Watchdog_Timer\Watchdog_Timer.eep" -m "C:\AVR_PROJECT\Watchdog_Timer\Watchdog_Timer.map" "C:\AVR_PROJECT\Watchdog_Timer\Watchdog_Timer.asm"
