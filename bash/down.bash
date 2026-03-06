#!/usr/bin/env bash
set -euo pipefail

NS="${NS:-default}"
SELECTOR="${SELECTOR:-app=turtlebot3,component=bringup}"
CONTAINER="${CONTAINER:-turtlebot3-bringup}"

ACTION="${1:-restart}"   # start|stop|restart

START_FILE="${START_FILE:-/shared/start_bringup}"
STOP_FILE="${STOP_FILE:-/shared/stop_bringup}"

POD="$(kubectl -n "$NS" get pod -l "$SELECTOR" \
  --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1].metadata.name}')"

echo "Using pod: $POD"
echo "Action: $ACTION"

case "$ACTION" in
  start)
    kubectl -n "$NS" exec "$POD" -c "$CONTAINER" -- sh -lc "set -eux; touch '$START_FILE'; ls -la /shared"
    ;;
  stop)
    kubectl -n "$NS" exec "$POD" -c "$CONTAINER" -- sh -lc "set -eux; touch '$STOP_FILE'; ls -la /shared"
    ;;
  restart)
    kubectl -n "$NS" exec "$POD" -c "$CONTAINER" -- sh -lc "set -eux; touch '$STOP_FILE'; touch '$START_FILE'; ls -la /shared"
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}" >&2
    exit 2
    ;;
esac