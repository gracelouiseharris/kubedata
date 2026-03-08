# kubedata


This repository contains the files necessary to recreate the generation of the dataset published here: https://drive.google.com/drive/u/1/folders/1ubCx1mP2Et0N3s3TGSI_uSlT1NtuFNpN

Steps for recreation:

RKE2 can be installed on nodes using the setup instructions found here: https://docs.rke2.io/install/quickstart

pv-setup.yaml and pvc-setup.yaml will set up the create the centralized storage needed for three layer telemetry. They write to an nfs share hosted on the server node. The IP and path to the nfs will need to be updated before applying. The cyclone-dds setup yaml and robot service yaml will also need to be applied before pod deployments are created. 

The yaml files found in the ROS, camera, lidar, daemons, and nginx folders can be applied with "kubectl apply -f file.yaml" to spin up pods. Once pods are running, run-mim.bash, run-flood.bash, run-all.bash, run-inject.bash, and run-benign.bash can be used to run the scenarios used to generate the data.

Each attack scenario was run for 60 seconds.

Lidar attack workflow:
--Run the benign cluster for 30 seconds.  
--Capture 1 second of lidar data using tcpdump.  
--Replay the captured data in a loop for the next 15 seconds via tcp from the attack container to the listener container.  
--Return to benign traffic for 15 seconds.  

Flood attack workflow:
--Run the benign cluster for 10 seconds.  
--Spin up the attacks pods.  
--Wait 10 more seconds.  
--20 seconds after packet capture begins: instruct one pod to flood the service for 10 seconds.  
--27 seconds after packet capture begins: instruct another pod to flood the service for 4 seconds.  
--45 seconds after packet capture begins: instruct another pod to flood the service for 1 second.  
--47 seconds after packet capture begins: instruct the final pod to flood the service for 1 second.  

Inject attack workflow:

--Enable the nmap pod that has been injected into the nginx pod to probe for all 60 seconds of data collection.
