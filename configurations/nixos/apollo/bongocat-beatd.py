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

from evdev import UInput, ecodes as e

# NOTE: aubio/numpy/scipy are imported lazily in run() — they cost 1-3s,
# and the uinput device must exist FIRST so the drums cat can start
# instantly (its launch script waits for the device to appear).

PW_RECORD = os.environ.get("BEATD_PWRECORD", "pw-record")
RATE = 22050
# pw-record otherwise requests a 100ms stream latency, which puts every paw
# hit visibly behind the music.  Keep the capture quantum and analysis hop in
# lockstep; at 22050Hz this is ~12ms per chunk.
LATENCY = os.environ.get("BEATD_LATENCY", "256")
HOP = 256
WIN = 512
SILENCE_FLOOR = float(os.environ.get("BEATD_SILENCE_FLOOR", "1e-4"))
KICK_HZ = 150
HAT_HZ = 5000
THRESHOLD = float(os.environ.get("BEATD_THRESHOLD", "0.4"))
KICK_MIN_IOI_MS = int(os.environ.get("BEATD_KICK_MIN_IOI_MS", "120"))
HAT_MIN_IOI_MS = int(os.environ.get("BEATD_HAT_MIN_IOI_MS", "90"))
ADAPTIVE_THRESHOLD = os.environ.get("BEATD_ADAPTIVE_THRESHOLD", "1") != "0"
TARGET_RMS = float(os.environ.get("BEATD_TARGET_RMS", "0.10"))
MIN_THRESHOLD = float(os.environ.get("BEATD_MIN_THRESHOLD", "0.15"))
MAX_THRESHOLD = float(os.environ.get("BEATD_MAX_THRESHOLD", "0.80"))
DEBUG = bool(os.environ.get("BEATD_DEBUG"))

KEY_KICK = e.BTN_TRIGGER_HAPPY1  # left paw
KEY_HAT = e.BTN_TRIGGER_HAPPY2  # right paw


def record_cmd():
    return [
        PW_RECORD,
        "--format=s16",
        f"--rate={RATE}",
        "--channels=1",
        f"--latency={LATENCY}",
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
    import aubio
    import numpy as np
    from scipy.signal import butter, lfilter, lfilter_zi

    lo_b, lo_a = butter(2, KICK_HZ / (RATE / 2), "low")
    hi_b, hi_a = butter(2, HAT_HZ / (RATE / 2), "high")
    zlo = lfilter_zi(lo_b, lo_a) * 0
    zhi = lfilter_zi(hi_b, hi_a) * 0
    kick = aubio.onset("hfc", WIN, HOP, RATE)
    kick.set_threshold(THRESHOLD)
    kick.set_minioi_ms(KICK_MIN_IOI_MS)
    hat = aubio.onset("hfc", WIN, HOP, RATE)
    hat.set_threshold(THRESHOLD)
    hat.set_minioi_ms(HAT_MIN_IOI_MS)
    # Aubio's HFC value scales with input level.  Follow the recent RMS
    # slowly, so a volume change does not turn quiet tracks inert or make loud
    # tracks chatter.  The bounds retain a predictable ceiling and floor.
    rms_ema = TARGET_RMS
    proc = subprocess.Popen(record_cmd(), stdout=subprocess.PIPE)
    try:
        while True:
            raw = proc.stdout.read(HOP * 2)
            if not raw or len(raw) < HOP * 2:
                return  # stream ended (device change etc.) -> restart
            s = np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768.0
            energy = float(np.mean(s * s))
            if energy < SILENCE_FLOOR:
                continue
            if ADAPTIVE_THRESHOLD:
                rms_ema = 0.98 * rms_ema + 0.02 * float(np.sqrt(energy))
                threshold = np.clip(
                    THRESHOLD * (rms_ema / TARGET_RMS),
                    MIN_THRESHOLD,
                    MAX_THRESHOLD,
                )
                kick.set_threshold(float(threshold))
                hat.set_threshold(float(threshold))
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
