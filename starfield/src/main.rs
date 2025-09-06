use pixels::{Error, Pixels, SurfaceTexture};
use rand::Rng;
use std::time::Instant;
use winit::{
    dpi::LogicalSize,
    event::{ElementState, Event, KeyboardInput, VirtualKeyCode, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

const WIDTH: u32 = 1920;
const HEIGHT: u32 = 1080;
const STAR_COUNT: usize = 5000;
const SHOOTING_STAR_GRAVITY: f32 = 30.0;
const STAR_MIN_SIZE: u32 = 1;
const STAR_MAX_SIZE: u32 = 4;
const STAR_MIN_SPEED: f32 = 5.0;
const STAR_MAX_SPEED: f32 = 25.0;

struct Star {
    x: f32,
    y: f32,
    speed: f32,
    twinkle_phase: f32,
    twinkle_speed: f32,
    depth: f32,
    color: (u8, u8, u8),
    size: u32,
}

struct ShootingStar {
    x: f32,
    y: f32,
    vx: f32,
    vy: f32,
    life: f32,
    max_life: f32,
    // Store previous positions for a natural trail
    trail: Vec<(f32, f32)>,
    trail_max_len: usize,
}

impl ShootingStar {
    fn new(start_x: f32, start_y: f32, vx: f32, vy: f32) -> Self {
        let max_life = 3.0; // Fixed lifetime for consistency
        Self {
            x: start_x,
            y: start_y,
            vx,
            vy,
            life: 0.0,
            max_life,
            trail: Vec::new(),
            trail_max_len: 80, // Much shorter, more manageable trail
        }
    }

    fn update(&mut self, dt: f32) {
        // Store current position in trail
        self.trail.push((self.x, self.y));
        if self.trail.len() > self.trail_max_len {
            self.trail.remove(0);
        }

        // Update physics
        self.x += self.vx * dt;
        self.vy += SHOOTING_STAR_GRAVITY * dt;
        self.y += self.vy * dt;
        self.life += dt;
    }

    fn is_alive(&self) -> bool {
        self.life < self.max_life
            && self.x > -200.0
            && self.x < WIDTH as f32 + 200.0
            && self.y > -200.0
            && self.y < HEIGHT as f32 + 200.0
    }

    fn draw(&self, frame: &mut [u8]) {
        let alpha = (1.0 - self.life / self.max_life).clamp(0.0, 1.0);

        // Draw trail using stored positions
        for (i, &(tx, ty)) in self.trail.iter().enumerate() {
            let trail_progress = i as f32 / self.trail.len() as f32;
            let trail_alpha = alpha * trail_progress * trail_progress; // Quadratic falloff

            if trail_alpha < 0.01 {
                continue; // Skip nearly invisible segments
            }

            // Color gradient: white/yellow at head to orange/red at tail
            let r = (255.0 * (0.8 + 0.2 * trail_progress)) as u8;
            let g = (255.0 * (0.6 + 0.4 * trail_progress)) as u8;
            let b = (100.0 + 155.0 * (1.0 - trail_progress)) as u8;

            // Variable width: thicker at head, thinner at tail
            let width = (1.0 + 3.0 * trail_progress) as i32;

            self.draw_point(frame, tx, ty, r, g, b, trail_alpha, width);
        }

        // Draw bright head
        if alpha > 0.01 {
            let head_size = 6;
            self.draw_point(frame, self.x, self.y, 255, 255, 220, alpha, head_size);
        }
    }

    fn draw_point(
        &self,
        frame: &mut [u8],
        x: f32,
        y: f32,
        r: u8,
        g: u8,
        b: u8,
        alpha: f32,
        size: i32,
    ) {
        let center_x = x as i32;
        let center_y = y as i32;

        for dx in -size / 2..=size / 2 {
            for dy in -size / 2..=size / 2 {
                let px = center_x + dx;
                let py = center_y + dy;

                if px >= 0 && px < WIDTH as i32 && py >= 0 && py < HEIGHT as i32 {
                    let idx = ((py as u32 * WIDTH + px as u32) * 4) as usize;

                    // Soft circular falloff
                    let dist = ((dx * dx + dy * dy) as f32).sqrt();
                    let radius = size as f32 / 2.0;
                    let falloff = (1.0 - (dist / radius).clamp(0.0, 1.0)).powf(2.0);
                    let final_alpha = (alpha * falloff).clamp(0.0, 1.0);

                    // Proper alpha blending
                    let old_r = frame[idx] as f32 / 255.0;
                    let old_g = frame[idx + 1] as f32 / 255.0;
                    let old_b = frame[idx + 2] as f32 / 255.0;

                    let new_r = r as f32 / 255.0;
                    let new_g = g as f32 / 255.0;
                    let new_b = b as f32 / 255.0;

                    frame[idx] =
                        ((old_r * (1.0 - final_alpha) + new_r * final_alpha) * 255.0) as u8;
                    frame[idx + 1] =
                        ((old_g * (1.0 - final_alpha) + new_g * final_alpha) * 255.0) as u8;
                    frame[idx + 2] =
                        ((old_b * (1.0 - final_alpha) + new_b * final_alpha) * 255.0) as u8;
                    frame[idx + 3] = 255;
                }
            }
        }
    }
}

fn main() -> Result<(), Error> {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_title("Starfield")
        .with_inner_size(LogicalSize::new(WIDTH as f64, HEIGHT as f64))
        .with_decorations(false)
        .with_fullscreen(Some(winit::window::Fullscreen::Borderless(None)))
        .build(&event_loop)
        .unwrap();

    let surface_texture = SurfaceTexture::new(WIDTH, HEIGHT, &window);
    let mut pixels = Pixels::new(WIDTH, HEIGHT, surface_texture)?;

    let mut rng = rand::thread_rng();
    let mut stars: Vec<Star> = (0..STAR_COUNT)
        .map(|_| {
            let palette = [
                (180, 200, 255), // blue
                (255, 255, 255), // white
                (255, 255, 200), // yellow
                (255, 220, 180), // orange
                (255, 180, 180), // red
            ];
            let color = palette[rng.gen_range(0..palette.len())];
            Star {
                x: rng.gen_range(0.0..WIDTH as f32),
                y: rng.gen_range(0.0..HEIGHT as f32),
                speed: rng.gen_range(STAR_MIN_SPEED..STAR_MAX_SPEED),
                twinkle_phase: rng.gen_range(0.0..std::f32::consts::TAU),
                twinkle_speed: rng.gen_range(1.0..3.0),
                depth: rng.gen_range(0.5..4.0),
                color,
                size: rng.gen_range(STAR_MIN_SIZE..=STAR_MAX_SIZE),
            }
        })
        .collect();

    let mut shooting_stars: Vec<ShootingStar> = Vec::new();
    let start = Instant::now();
    let mut last_frame = start;

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Poll;

        match event {
            Event::RedrawRequested(_) => {
                let now = Instant::now();
                let dt = (now - last_frame).as_secs_f32();
                last_frame = now;

                let elapsed = start.elapsed().as_secs_f32();
                let frame = pixels.frame_mut();
                frame.fill(0);

                // Update and draw regular stars
                for star in &mut stars {
                    star.speed *= 0.999_f32.powf(dt * 60.0);
                    star.x -= star.speed * star.depth * dt;
                    if star.x < 0.0 {
                        star.x = WIDTH as f32;
                        star.y = rng.gen_range(0.0..HEIGHT as f32);
                        star.depth = rng.gen_range(0.5..2.0);
                        star.twinkle_phase = rng.gen_range(0.0..std::f32::consts::TAU);
                        star.twinkle_speed = rng.gen_range(1.0..3.0);
                        star.speed = rng.gen_range(STAR_MIN_SPEED..STAR_MAX_SPEED);
                        star.size = rng.gen_range(STAR_MIN_SIZE..=STAR_MAX_SIZE);
                    }

                    let twinkle =
                        (elapsed * star.twinkle_speed + star.twinkle_phase).sin() * 0.5 + 0.5;
                    let intensity = (twinkle * 255.0 / star.depth).min(255.0) as u8;

                    let (base_r, base_g, base_b) = star.color;
                    let r = ((base_r as f32 * (intensity as f32 / 255.0)).min(255.0)) as u8;
                    let g = ((base_g as f32 * (intensity as f32 / 255.0)).min(255.0)) as u8;
                    let b = ((base_b as f32 * (intensity as f32 / 255.0)).min(255.0)) as u8;

                    for dx in 0..star.size {
                        for dy in 0..star.size {
                            let ix = star.x as i32 + dx as i32;
                            let iy = star.y as i32 + dy as i32;
                            if ix >= 0 && ix < WIDTH as i32 && iy >= 0 && iy < HEIGHT as i32 {
                                let idx = ((iy as u32 * WIDTH + ix as u32) * 4) as usize;
                                frame[idx] = r;
                                frame[idx + 1] = g;
                                frame[idx + 2] = b;
                                frame[idx + 3] = 255;
                            }
                        }
                    }
                }

                // Spawn shooting stars less frequently but more predictably
                if rng.gen_bool(dt as f64 * 0.3) {
                    // About 1 every 3-4 seconds
                    let start_x = WIDTH as f32 + 50.0; // Start off-screen
                    let start_y = rng.gen_range(50.0..HEIGHT as f32 * 0.4);
                    let vx = -rng.gen_range(200.0..400.0); // Faster horizontal speed
                    let vy = rng.gen_range(10.0..50.0); // Moderate downward speed

                    shooting_stars.push(ShootingStar::new(start_x, start_y, vx, vy));
                }

                // Update and draw shooting stars
                shooting_stars.retain_mut(|star| {
                    star.update(dt);
                    star.draw(frame);
                    star.is_alive()
                });

                if pixels.render().is_err() {
                    *control_flow = ControlFlow::Exit;
                }
            }
            Event::MainEventsCleared => {
                window.request_redraw();
            }
            Event::WindowEvent { event, .. } => {
                if let WindowEvent::KeyboardInput {
                    input:
                        KeyboardInput {
                            virtual_keycode: Some(VirtualKeyCode::Escape),
                            state: ElementState::Pressed,
                            ..
                        },
                    ..
                } = event
                {
                    *control_flow = ControlFlow::Exit;
                }
            }
            _ => {}
        }
    });
}
