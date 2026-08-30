"""Beat tracker -> virtual gamepad for bongocat.

Taps the default PipeWire sink monitor and runs aubio's streaming tempo
tracker (real beat detection: onset + tempo estimation + phase lock,
NOT a loudness gate), emitting alternating BTN_TRIGGER_HAPPY1/2 events
- joystick-range codes that produce no text and are ignored by the
compositor - on a 'bongobeat' uinput device. bongocat's drums variant
listens only to this device, so the cat drums on the beat.
"""

import os
import subprocess
import sys
import time

import aubio
import numpy as np
from evdev import UInput, ecodes as e

PW_RECORD = os.environ.get("BEATD_PWRECORD", "pw-record")
RATE = 22050
HOP = 512  # samples (~23ms)
WIN = 1024
SILENCE_FLOOR = 1e-4  # mean-square, float scale: don't drum at silence
DEBUG = bool(os.environ.get("BEATD_DEBUG"))

KEYS = [e.BTN_TRIGGER_HAPPY1, e.BTN_TRIGGER_HAPPY2]  # no text output, ever


def record_cmd():
    return [
        PW_RECORD,
        "--format=s16",
        f"--rate={RATE}",
        "--channels=1",
        "-P",
        "{ stream.capture.sink = true }",
        "-",
    ]


def run(ui):
    tracker = aubio.tempo("default", WIN, HOP, RATE)
    which = 0
    proc = subprocess.Popen(record_cmd(), stdout=subprocess.PIPE)
    try:
        while True:
            raw = proc.stdout.read(HOP * 2)
            if not raw or len(raw) < HOP * 2:
                return  # stream ended (device change etc.) -> restart
            samples = np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768.0
            is_beat = tracker(samples)[0]
            if is_beat and float(np.mean(samples * samples)) > SILENCE_FLOOR:
                key = KEYS[which]
                which ^= 1
                ui.write(e.EV_KEY, key, 1)
                ui.syn()
                ui.write(e.EV_KEY, key, 0)
                ui.syn()
                if DEBUG:
                    print(f"beat bpm={tracker.get_bpm():.1f}", flush=True)
    finally:
        proc.kill()
        proc.wait()


def main():
    ui = UInput({e.EV_KEY: KEYS}, name="bongobeat")
    print("bongobeat uinput device up", flush=True)
    while True:
        try:
            run(ui)
        except Exception as exc:  # keep drumming through hiccups
            print(f"beatd: {exc}", file=sys.stderr, flush=True)
        time.sleep(1)


if __name__ == "__main__":
    main()
