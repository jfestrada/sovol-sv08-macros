#!/bin/bash

NEWY=$(ls -Art /tmp/resonances_y_*.csv | tail -n 1)
DATE=$(date +'%Y-%m-%d-%H%M%S')
if [ ! -d "/home/sovol/printer_data/config/input_shaper" ]
then
    mkdir /home/sovol/printer_data/config/input_shaper
    chwn sovol:sovol /home/sovol/printer_data/config/input_shaper
fi

~/klipper/scripts/calibrate_shaper.py $NEWY -o /home/sovol/printer_data/config/input_shaper/resonances_y_$DATE.png

