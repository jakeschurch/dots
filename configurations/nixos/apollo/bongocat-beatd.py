"""Beat detector -> virtual keyboard for bongocat.

Taps the default PipeWire sink monitor, runs a simple adaptive
energy-onset detector, and emits alternating button events
(BTN_TRIGGER_HAPPY1/2 - joystick-range codes that produce NO text and
are ignored by the compositor) on a 'bongobeat' uinput device. bongocat's drums variant listens only to
this device, so the cat drums along with whatever is playing.
"""

import collections
import os
import subprocess
import sys
import time
from array import array

from evdev import UInput, ecodes as e

PW_RECORD = os.environ.get("BEATD_PWRECORD", "pw-record")
RATE = 22050
CHUNK = 512  # samples (~23ms)
WINDOW = 40  # chunks of history (~0.93s)
RATIO = 1.7  # onset = energy > RATIO * rolling average
FLOOR = 1.5e5  # ignore silence/noise (s16 mean-square units)
COOLDOWN = 0.18  # min seconds between slaps (~330 BPM ceiling)
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
    hist = collections.deque(maxlen=WINDOW)
    last = 0.0
    which = 0
    proc = subprocess.Popen(record_cmd(), stdout=subprocess.PIPE)
    try:
        while True:
            raw = proc.stdout.read(CHUNK * 2)
            if not raw or len(raw) < CHUNK * 2:
                return  # stream ended (device change etc.) -> restart
            samples = array("h", raw)
            energy = sum(v * v for v in samples) / len(samples)
            avg = (sum(hist) / len(hist)) if hist else 0.0
            hist.append(energy)
            now = time.monotonic()
            if (
                len(hist) > 10
                and energy > FLOOR
                and avg > 0
                and energy > RATIO * avg
                and now - last > COOLDOWN
            ):
                last = now
                key = KEYS[which]
                which ^= 1
                ui.write(e.EV_KEY, key, 1)
                ui.syn()
                ui.write(e.EV_KEY, key, 0)
                ui.syn()
                if DEBUG:
                    print(f"beat {energy:.0f} avg {avg:.0f}", flush=True)
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
