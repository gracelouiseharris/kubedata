#!/usr/bin/env python3
import time
import os
import subprocess
import sys
import random
import signal
from threading import Event

# Path that controls whether traffic generation should be running.
# File must exist and contain "1" (exactly) to enable traffic.
TRIGGER_PATH = "/shared/tcpdump_enable"

# File used to tell the tcpdump controller to start/stop (created when traffic starts).
TCPDUMP_TRIGGER = "/shared/tcpdump_enable_signal"

# How long to sleep between trigger polls (s)
POLL_INTERVAL = 1.0

shutdown_event = Event()

def _log(msg):
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    print(f"[traffic.py] {ts} - {msg}", flush=True)

def read_trigger():
    """Return the stripped trigger file content, or None if file missing/read error."""
    try:
        with open(TRIGGER_PATH, "r") as f:
            return f.read().strip()
    except Exception:
        return None

def create_tcpdump_trigger():
    try:
        with open(TCPDUMP_TRIGGER, "w") as f:
            f.write("start\n")
        _log(f"Created tcpdump trigger: {TCPDUMP_TRIGGER}")
    except Exception as e:
        _log(f"Failed to create tcpdump trigger: {e}")

def remove_tcpdump_trigger():
    try:
        if os.path.exists(TCPDUMP_TRIGGER):
            os.remove(TCPDUMP_TRIGGER)
            _log(f"Removed tcpdump trigger: {TCPDUMP_TRIGGER}")
    except Exception as e:
        _log(f"Failed to remove tcpdump trigger: {e}")

def generate_random_traffic_once():
    """Pick one of several small traffic-generation commands and run it."""
    commands = [
        lambda: subprocess.run(["curl", "-s", "http://localhost:8080"]),
        lambda: subprocess.run(["nc", "localhost", "8080"], input=b"TCP test\n"),
        lambda: subprocess.run(["nc", "-u", "-w1", "localhost", "8080"], input=b"UDP test\n"),
        lambda: subprocess.run(["ping", "-c", "1", "127.0.0.1"]),
        lambda: subprocess.run(["nslookup", "example.com"])
    ]
    try:
        random.choice(commands)()
    except FileNotFoundError as e:
        # One of the command-line tools may not be installed in the environment.
        _log(f"Command not found: {e}")
    except Exception as e:
        _log(f"Error running traffic command: {e}")

def signal_handler(signum, frame):
    _log(f"Received signal {signum}, shutting down...")
    shutdown_event.set()

def main_loop():
    _log("Starting main loop. Waiting for trigger to start traffic generation...")
    try:
        while not shutdown_event.is_set():
            # Wait until trigger exists and equals "1"
            while not shutdown_event.is_set():
                val = read_trigger()
                if val == "1":
                    break
                time.sleep(POLL_INTERVAL)

            if shutdown_event.is_set():
                break

            # Trigger detected: start tcpdump trigger and generate traffic until trigger removed
            _log("Trigger detected, enabling tcpdump and starting traffic generation...")
            create_tcpdump_trigger()

            try:
                while not shutdown_event.is_set():
                    val = read_trigger()
                    if val != "1":
                        _log("Trigger removed or changed. Stopping traffic generation...")
                        break

                    _log("Generating random traffic...")
                    generate_random_traffic_once()

                    # Random sleep time between 10 and 2000 ms
                    time.sleep(0.001 * random.randint(10, 2000))

            finally:
                # Ensure tcpdump trigger is removed when we stop traffic or on exceptions
                remove_tcpdump_trigger()
                _log("Traffic generation stopped. Returning to waiting for trigger...")
                # loop continues to wait for trigger again

    except Exception as e:
        _log(f"Unhandled exception in main loop: {e}")
    finally:
        # Final cleanup
        remove_tcpdump_trigger()
        _log("Exiting.")
        # Note: don't call sys.exit() inside library-like code; it's fine here
        sys.exit(0)

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    main_loop()
