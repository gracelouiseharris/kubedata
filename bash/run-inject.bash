bash start_ptcp.bash
bash daemon-enable.bash
bash enable-robot.bash
bash camera-live-enable.bash
bash lidar-live-enable.bash
bash nmap-enable.bash

echo "started job, sleeping"
sleep 60

bash daemon-disable.bash
bash camera-live-disable.bash
bash lidar-live-disable.bash
bash nmap-live-disable.bash
bash nginx-live-disable.bash
bash disable-robot.bash
bash end_ptcp.bash