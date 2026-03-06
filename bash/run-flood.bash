bash start_ptcp.bash
bash daemon-enable.bash
bash camera-live-enable.bash
bash lidar-live-enable.bash
bash nginx-live-enable.bash
bash enable-robot.bash

sleep 5

kubectl apply -f web-attack.yaml
echo "creating pods"

sleep 10

bash schedule-load.sh "5:10" "12:4" "30:1" "32:1"

sleep 45

bash disable-robot.bash
bash daemon-disable.bash
bash camera-live-disable.bash
bash lidar-live-disable.bash
bash nginx-live-disable.bash
bash end_ptcp.bash

