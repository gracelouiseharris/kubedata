#!/bin/bash
bash start_ptcp.bash
bash daemon-enable.bash
bash enable-robot.bash
bash camera-live-enable.bash
bash lidar-live-enable.bash
bash nginx-live-enable.bash

sleep 15
echo "started job, sleeping"

bash mim_attack.bash
sleep 45

bash daemon-disable.bash
bash camera-live-disable.bash
bash lidar-live-disable.bash
bash nginx-live-disable.bash
bash disable-robot.bash
bash end_ptcp.bash
