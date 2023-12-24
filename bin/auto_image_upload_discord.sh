#!/usr/bin/env bash
sleep .1  # Wait for ydotool's virtual device to start
sudo /usr/bin/ydotool mousemove --absolute 310 450
sudo /usr/bin/ydotool click 0xC0
sudo /usr/bin/ydotool mousemove -- 20 -40
sudo /usr/bin/ydotool click 0xC0
sleep .2  # Takes a bit to pull up window
sudo /usr/bin/ydotool mousemove --absolute 110 150
sudo /usr/bin/ydotool click 0xC0
sudo /usr/bin/ydotool mousemove --absolute 210 120
sudo /usr/bin/ydotool click -r 2 -d 100 0xC0
