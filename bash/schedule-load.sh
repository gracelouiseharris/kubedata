#!/usr/bin/env bash

# -------------------------------------------------------------------
# schedule_load.sh
#
# Controls your k6 load-generator pods using trigger files.
# Usage example:
#   ./schedule_load.sh "0:30" "10:20" "60:15"
#
# Each argument is START:SECONDS_TO_RUN
# (One argument per pod, discovered automatically by label.)
# -------------------------------------------------------------------

LABEL_SELECTOR="app=traffic-gen"
HELPER_CONTAINER="helper"

echo "Discovering load-generator pods..."
PODS=($(kubectl get pods -l ${LABEL_SELECTOR} -o jsonpath='{.items[*].metadata.name}'))

NUM_PODS=${#PODS[@]}
NUM_ARGS=$#

if [ $NUM_ARGS -eq 0 ]; then
  echo "Usage: $0 START:RUN_DURATION [START:RUN_DURATION ...]"
  echo "Example: $0 \"0:30\" \"10:60\" \"120:45\""
  exit 1
fi

if [ $NUM_ARGS -ne $NUM_PODS ]; then
  echo "ERROR: Number of parameters ($NUM_ARGS) does not match number of pods ($NUM_PODS)"
  echo "Pods found: ${PODS[@]}"
  exit 1
fi

echo "Pods found:"
for i in "${!PODS[@]}"; do
  echo "  [$i] ${PODS[$i]}"
done

start_load() {
  local pod=$1
  echo "Starting load on pod: $pod"
  kubectl exec "$pod" -c "$HELPER_CONTAINER" -- sh -c "touch /trigger/start"
}

stop_load() {
  local pod=$1
  echo "Stopping load on pod: $pod"
  kubectl exec "$pod" -c "$HELPER_CONTAINER" -- sh -c "rm -f /trigger/start"
}

for i in "${!PODS[@]}"; do
  PARAM=${!i}
  POD=${PODS[$i]}

  START_TIME=$(echo "$PARAM" | cut -d':' -f1)
  RUN_TIME=$(echo "$PARAM"  | cut -d':' -f2)

  (
    echo "[$POD] Scheduled start in $START_TIME seconds; run for $RUN_TIME seconds."

    sleep "$START_TIME"
    start_load "$POD"
    
    sleep "$RUN_TIME"
    stop_load "$POD"

    echo "[$POD] Completed schedule."
  ) &

done

echo "All schedules started in background."
echo "Use 'jobs -l' to view running timers."
wait
