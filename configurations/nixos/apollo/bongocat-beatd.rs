//! Native beat-grid tracker for the Bongo Cat virtual input.
//!
//! This deliberately models the repeating musical pulse instead of attempting
//! impossible instrument separation from a mixed stereo master.  It derives a
//! transient envelope from PipeWire PCM, finds its most likely 80–180 BPM
//! period by autocorrelation, then locks the virtual key to the strongest
//! repeating phase of that period.

use std::collections::VecDeque;
use std::fs::{File, OpenOptions};
use std::io::{Read, Write};
use std::os::unix::fs::OpenOptionsExt;
use std::process::{Command, Stdio};

const RATE: usize = 22_050;
const HOP: usize = 256;
// Eight seconds gives the autocorrelation enough repeated bars to reject
// individual 808s, fills, and half/double-time accents.
const HISTORY: usize = RATE * 8 / HOP;
const KEY_BEAT: u16 = 704; // BTN_TRIGGER_HAPPY1
const EV_KEY: u16 = 1;
const EV_SYN: u16 = 0;
const SYN_REPORT: u16 = 0;

extern "C" { fn ioctl(fd: i32, request: u64, ...) -> i32; }
const fn iow(nr: u64) -> u64 { (1 << 30) | (85 << 8) | nr | (4 << 16) }
const UI_SET_EVBIT: u64 = iow(100);
const UI_SET_KEYBIT: u64 = iow(101);
const UI_DEV_CREATE: u64 = (85 << 8) | 1;
const UI_DEV_DESTROY: u64 = (85 << 8) | 2;

#[repr(C)]
struct UinputUserDev {
    name: [u8; 80], bustype: u16, vendor: u16, product: u16, version: u16,
    ff_effects_max: i32, absmax: [i32; 64], absmin: [i32; 64],
    absfuzz: [i32; 64], absflat: [i32; 64],
}
#[repr(C)]
struct InputEvent { sec: i64, usec: i64, kind: u16, code: u16, value: i32 }

struct Uinput(File);
impl Uinput {
    fn new() -> std::io::Result<Self> {
        let mut file = OpenOptions::new().write(true).custom_flags(0o4000).open("/dev/uinput")?;
        unsafe {
            if ioctl(file.as_raw_fd(), UI_SET_EVBIT, EV_KEY as i32) < 0 ||
               ioctl(file.as_raw_fd(), UI_SET_KEYBIT, KEY_BEAT as i32) < 0 { return Err(std::io::Error::last_os_error()); }
        }
        let mut dev: UinputUserDev = unsafe { std::mem::zeroed() };
        dev.name[..9].copy_from_slice(b"bongobeat"); dev.bustype = 0x03;
        file.write_all(unsafe { std::slice::from_raw_parts((&dev as *const UinputUserDev).cast(), std::mem::size_of::<UinputUserDev>()) })?;
        if unsafe { ioctl(file.as_raw_fd(), UI_DEV_CREATE) } < 0 { return Err(std::io::Error::last_os_error()); }
        Ok(Self(file))
    }
    fn tap(&mut self) -> std::io::Result<()> {
        for (kind, code, value) in [(EV_KEY, KEY_BEAT, 1), (EV_SYN, SYN_REPORT, 0), (EV_KEY, KEY_BEAT, 0), (EV_SYN, SYN_REPORT, 0)] {
            let event = InputEvent { sec: 0, usec: 0, kind, code, value };
            self.0.write_all(unsafe { std::slice::from_raw_parts((&event as *const InputEvent).cast(), std::mem::size_of::<InputEvent>()) })?;
        }
        Ok(())
    }
}
impl Drop for Uinput { fn drop(&mut self) { unsafe { ioctl(self.0.as_raw_fd(), UI_DEV_DESTROY); } } }
use std::os::fd::AsRawFd;

struct BeatGrid { history: VecDeque<f32>, baseline: f32, frame: usize, period: usize, next: usize, locked: bool }
impl BeatGrid {
    fn new() -> Self { Self { history: VecDeque::with_capacity(HISTORY), baseline: 0.0, frame: 0, period: 0, next: usize::MAX, locked: false } }
    fn push(&mut self, samples: &[i16]) -> bool {
        let rms = (samples.iter().map(|x| (*x as f32 / 32768.0).powi(2)).sum::<f32>() / samples.len() as f32).sqrt();
        self.baseline = self.baseline * 0.985 + rms * 0.015;
        let transient = (rms - self.baseline).max(0.0);
        if self.history.len() == HISTORY { self.history.pop_front(); }
        self.history.push_back(transient); self.frame += 1;
        if self.frame % 86 == 0 && self.history.len() == HISTORY { self.relock(); }
        if self.frame >= self.next { self.next = self.next.saturating_add(self.period.max(1)); return self.period != 0; }
        false
    }
    fn relock(&mut self) {
        let h: Vec<f32> = self.history.iter().copied().collect();
        let (mut best_lag, mut best_score) = (0, f32::MIN);
        for lag in 29..=65 { // 180..80 BPM at this hop size
            let score = (lag..h.len()).map(|i| h[i] * h[i-lag]).sum::<f32>();
            if score > best_score { best_score = score; best_lag = lag; }
        }
        if best_lag == 0 || best_score <= 0.0 { return; }
        // A nearby estimate is normal jitter, so smooth it heavily.  A large
        // change means a new track or a real tempo change and earns a new
        // phase lock instead of dragging the old song's phase into the new one.
        let new_track = !self.locked || best_lag.abs_diff(self.period) * 100 > self.period * 15;
        self.period = if new_track { best_lag } else { (self.period * 7 + best_lag) / 8 };
        let start = self.frame - h.len();
        let mut phase = 0; let mut phase_score = f32::MIN;
        for candidate in 0..self.period {
            let score = h.iter().enumerate().filter(|(i, _)| (start + *i + self.period - candidate) % self.period <= 1).map(|(_, v)| *v).sum::<f32>();
            if score > phase_score { phase_score = score; phase = candidate; }
        }
        if new_track {
            self.next = self.frame + (self.period - ((self.frame - phase) % self.period)) % self.period;
            self.locked = true;
        }
    }
}

fn main() -> std::io::Result<()> {
    let pw = std::env::var("BEATD_PWRECORD").unwrap_or_else(|_| "pw-record".into());
    let latency = std::env::var("BEATD_LATENCY").unwrap_or_else(|_| "256".into());
    let mut command = Command::new(pw);
    command.args(["--format=s16", "--rate=22050", "--channels=1"])
        .arg(format!("--latency={latency}"))
        .args(["-P", "{ stream.capture.sink = true }", "-"])
        .stdout(Stdio::piped());
    let mut child = command.spawn()?;
    let mut audio = child.stdout.take().unwrap(); let mut ui = Uinput::new()?; let mut grid = BeatGrid::new(); let mut bytes = [0u8; HOP * 2];
    while audio.read_exact(&mut bytes).is_ok() {
        let mut samples = [0i16; HOP]; for (i, pair) in bytes.chunks_exact(2).enumerate() { samples[i] = i16::from_le_bytes([pair[0], pair[1]]); }
        if grid.push(&samples) { ui.tap()?; }
    }
    let _ = child.kill(); Ok(())
}
