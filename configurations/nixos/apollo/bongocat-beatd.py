"""Percussion tracker -> virtual gamepad for bongocat.

Taps the default PipeWire sink monitor, splits it into two bands, and
runs an aubio onset detector on each:

  low band  (<150Hz, kick drum)      -> BTN_TRIGGER_HAPPY1 (left paw)
  high band (>5kHz, hi-hats/snare)   -> BTN_TRIGGER_HAPPY2 (right paw)

So the cat plays along with the actual drum hits rather than a
predicted tempo grid. Button codes are joystick-range: they produce no
text and the compositor ignores them; only bongocat's drums variant
listens to the 'bongobeat' uinput device they land on.
"""

import os
import subprocess
import sys
import time

import aubio
import numpy as np
from evdev import UInput, ecodes as e
from scipy.signal import butter, lfilter, lfilter_zi

PW_RECORD = os.environ.get("BEATD_PWRECORD", "pw-record")
RATE = 22050
HOP = 512  # samples (~23ms)
WIN = 1024
SILENCE_FLOOR = 1e-4  # mean-square, float scale: don't drum at silence
KICK_HZ = 150
HAT_HZ = 5000
THRESHOLD = float(os.environ.get("BEATD_THRESHOLD", "0.4"))
DEBUG = bool(os.environ.get("BEATD_DEBUG"))

KEY_KICK = e.BTN_TRIGGER_HAPPY1  # left paw
KEY_HAT = e.BTN_TRIGGER_HAPPY2  # right paw


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


def tap(ui, key):
    ui.write(e.EV_KEY, key, 1)
    ui.syn()
    ui.write(e.EV_KEY, key, 0)
    ui.syn()


def run(ui):
    lo_b, lo_a = butter(2, KICK_HZ / (RATE / 2), "low")
    hi_b, hi_a = butter(2, HAT_HZ / (RATE / 2), "high")
    zlo = lfilter_zi(lo_b, lo_a) * 0
    zhi = lfilter_zi(hi_b, hi_a) * 0
    kick = aubio.onset("hfc", WIN, HOP, RATE)
    kick.set_threshold(THRESHOLD)
    kick.set_minioi_ms(120)
    hat = aubio.onset("hfc", WIN, HOP, RATE)
    hat.set_threshold(THRESHOLD)
    hat.set_minioi_ms(90)
    proc = subprocess.Popen(record_cmd(), stdout=subprocess.PIPE)
    try:
        while True:
            raw = proc.stdout.read(HOP * 2)
            if not raw or len(raw) < HOP * 2:
                return  # stream ended (device change etc.) -> restart
            s = np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768.0
            if float(np.mean(s * s)) < SILENCE_FLOOR:
                continue
            lo, zlo = lfilter(lo_b, lo_a, s, zi=zlo)
            hi, zhi = lfilter(hi_b, hi_a, s, zi=zhi)
            k = kick(lo.astype(np.float32))[0]
            h = hat(hi.astype(np.float32))[0]
            if k:
                tap(ui, KEY_KICK)
            if h:
                tap(ui, KEY_HAT)
            if DEBUG and (k or h):
                print(f"{'KICK' if k else '    '} {'hat' if h else ''}", flush=True)
    finally:
        proc.kill()
        proc.wait()


def main():
    ui = UInput({e.EV_KEY: [KEY_KICK, KEY_HAT]}, name="bongobeat")
    print("bongobeat uinput device up", flush=True)
    while True:
        try:
            run(ui)
        except Exception as exc:  # keep drumming through hiccups
            print(f"beatd: {exc}", file=sys.stderr, flush=True)
        time.sleep(1)


if __name__ == "__main__":
    main()
