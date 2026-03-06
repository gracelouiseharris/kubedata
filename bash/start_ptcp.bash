#!/usr/bin/env bash
set -euo pipefail

############################################
# Config
############################################
OUT_DIR="/home/grace/Desktop/"
CRI_SOCK="/run/k3s/containerd/containerd.sock"
CAPTURE_DURATION_MIN="${CAPTURE_DURATION_MIN:-60}"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
mkdir -p "${OUT_DIR}"

PTCP_ANY_PCAP="${OUT_DIR}/router-any-ptcp.pcapng"
PTCP_OVERLAY_PCAP="${OUT_DIR}/router-flannel-ptcp.pcapng"
TCP_ANY_PCAP="${OUT_DIR}/router-any-tcp.pcapng"
TCP_OVERLAY_PCAP="${OUT_DIR}/router-flannel-tcp.pcapng"

PID_FILE="${OUT_DIR}/capture_pids_${TIMESTAMP}.txt"
LOG_FILE="${OUT_DIR}/capture_${TIMESTAMP}.log"

echo "Starting background packet capture (timeout ${CAPTURE_DURATION_MIN} min)"
echo "Logs: ${LOG_FILE}"

############################################
# Start captures
############################################
sudo ptcpdump -i any -w "${PTCP_ANY_PCAP}" --cri-runtime-address "${CRI_SOCK}" >>"${LOG_FILE}" 2>&1 &
PID_PTCP_ANY=$!

sudo ptcpdump -i flannel.1 -w "${PTCP_OVERLAY_PCAP}" --cri-runtime-address "${CRI_SOCK}" >>"${LOG_FILE}" 2>&1 &
PID_PTCP_OVERLAY=$!

sudo tcpdump -i any -s 0 -B 4096 -w "${TCP_ANY_PCAP}" >>"${LOG_FILE}" 2>&1 &
PID_TCP_ANY=$!

sudo tcpdump -i flannel.1 -s 0 -B 4096 -w "${TCP_OVERLAY_PCAP}" >>"${LOG_FILE}" 2>&1 &
PID_TCP_OVERLAY=$!
