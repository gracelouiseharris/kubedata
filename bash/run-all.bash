#!/bin/bash
bash daemon-enable.bash
bash camera-live-enable.bash
bash lidar-live-enable.bash
bash nginx-live-enable.bash

echo "started job, sleeping"
sleep 120
echo "2 mins"
sleep 120
echo "4 mins"
sleep 120
echo "6 mins"
sleep 120
echo "8 mins"
sleep 120

bash daemon-disable.bash
bash camera-live-disable.bash
bash lidar-live-disable.bash
bash nginx-live-disable.bash