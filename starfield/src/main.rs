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
const SHOOTING_STAR_GRAVITY: f32 = 20.0;
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
    color: (u8, u8, u8), // RGB color
    size: u32,
}

struct ShootingStar {
    x: f32,
    y: f32,
    vx: f32,
    vy: f32,
    life: f32,
    max_life: f32,
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
            // Star color palette: blue, white, yellow, orange, red
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

                for star in &mut stars {
                    // Slow down stars over time (friction)
                    star.speed *= 0.999_f32.powf(dt * 60.0); // gentle friction
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

                    // Twinkle factor
                    let twinkle =
                        (elapsed * star.twinkle_speed + star.twinkle_phase).sin() * 0.5 + 0.5;
                    let intensity = (twinkle * 255.0 / star.depth).min(255.0) as u8;

                    // Use star color tint
                    let (base_r, base_g, base_b) = star.color;
                    let r = ((base_r as f32 * (intensity as f32 / 255.0)).min(255.0)) as u8;
                    let g = ((base_g as f32 * (intensity as f32 / 255.0)).min(255.0)) as u8;
                    let b = ((base_b as f32 * (intensity as f32 / 255.0)).min(255.0)) as u8;

                    // Draw a star.size x star.size block
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

                // Randomly spawn shooting stars
                if rng.gen_bool(dt as f64 * 0.05) {
                    // ~0.05 per second (about 1 every 20 seconds)
                    // Always start at right edge, random y in top 30%
                    let start_x = WIDTH as f32;
                    let start_y = rng.gen_range(0.0..HEIGHT as f32 * 0.3);
                    // Negative vx so it goes left, small vy for slight downward angle
                    let vx = -rng.gen_range(80.0..160.0) as f32; // slow, but enough to cross screen
                    let vy = rng.gen_range(5.0..30.0) as f32;
                    // Tail length in pixels (should match len in tail drawing)
                    let tail_length = 1280.0f32 * 0.015f32 * vx.abs();
                    // Time to cross the screen (plus a bit for tail)
                    let max_life = (start_x + tail_length) / vx.abs();
                    shooting_stars.push(ShootingStar {
                        x: start_x,
                        y: start_y,
                        vx,
                        vy,
                        life: 0.0,
                        max_life,
                    });
                }

                // Update and draw shooting stars
                shooting_stars.retain_mut(|s| {
                    s.x += s.vx * dt;
                    s.vy += SHOOTING_STAR_GRAVITY * dt;
                    s.y += s.vy * dt;
                    s.life += dt;
                    let alpha = (1.0 - s.life / s.max_life).clamp(0.0, 1.0);
                    let len = 6000.0; // much longer tail
                    for i in 0..len as i32 {
                        let t = i as f32 / len;
                        let fx = s.x - s.vx * t * 0.018;
                        let fy = s.y - s.vy * t * 0.018;
                        let fade = alpha * (1.0 - t).powf(2.0) * 0.7 + 0.05;
                        let r = (255.0 * (1.0 - t) + 100.0 * t) as u8;
                        let g = (255.0 * (1.0 - t) + 180.0 * t) as u8;
                        let b = (255.0 * (1.0 - t) + 255.0 * t) as u8;
                        // Tapered width: thick at head, thin at tail
                        let width = ((1.0 - t) * 8.0).ceil() as i32; // 8px at head, 1px at tail
                        for dx in -width/2..=width/2 {
                            for dy in -width/2..=width/2 {
                                let tx = fx as i32 + dx;
                                let ty = fy as i32 + dy;
                                if tx >= 0 && tx < WIDTH as i32 && ty >= 0 && ty < HEIGHT as i32 {
                                    // Fade more at the edge for a soft edge
                                    let dist = ((dx*dx + dy*dy) as f32).sqrt() / (width as f32);
                                    let edge_fade = 1.0 - dist.clamp(0.0, 1.0);
                                    let final_fade = fade * edge_fade;
                                    let idx = ((ty as u32 * WIDTH + tx as u32) * 4) as usize;
                                    frame[idx] = ((frame[idx] as f32 * (1.0 - final_fade)) + (r as f32 * final_fade)) as u8;
                                    frame[idx + 1] = ((frame[idx + 1] as f32 * (1.0 - final_fade)) + (g as f32 * final_fade)) as u8;
                                    frame[idx + 2] = ((frame[idx + 2] as f32 * (1.0 - final_fade)) + (b as f32 * final_fade)) as u8;
                                    frame[idx + 3] = 255;
                                }
                            }
                        }
                    }
                                        as u8;
                                    frame[idx + 3] = 255;
                                }
                            }
                        }
                    }
                    // Draw a larger head for the shooting star (e.g., 4x4 block)
                    let head_size = 4;
                    // Head color: bright white/yellow
                    let (r, g, b) = (255u8, 255u8, 220u8);
                    for dx in 0..head_size {
                        for dy in 0..head_size {
                            let hx = s.x as i32 + dx;
                            let hy = s.y as i32 + dy;
                            if hx >= 0 && hx < WIDTH as i32 && hy >= 0 && hy < HEIGHT as i32 {
                                let idx = ((hy as u32 * WIDTH + hx as u32) * 4) as usize;
                                frame[idx] = r;
                                frame[idx + 1] = g;
                                frame[idx + 2] = b;
                                frame[idx + 3] = 255;
                            }
                        }
                    }
                    s.life < s.max_life && s.x > -100.0 && s.y < HEIGHT as f32 + 100.0
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
