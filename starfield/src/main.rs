use pixels::{Error, Pixels, SurfaceTexture};
use rand::Rng;
use std::time::Instant;
use winit::event::{ElementState, KeyboardInput, VirtualKeyCode, WindowEvent};
use winit::{
    dpi::LogicalSize,
    event::{Event, VirtualKeyCode, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

const WIDTH: u32 = 1920;
const HEIGHT: u32 = 1080;
const STAR_COUNT: usize = 500;
const STAR_SIZE: u32 = 2; // Size of each star (2x2 pixels)

struct Star {
    x: f32,
    y: f32,
    speed: f32,
    twinkle_phase: f32,
    twinkle_speed: f32,
    depth: f32,
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
        .map(|_| Star {
            x: rng.gen_range(0.0..WIDTH as f32),
            y: rng.gen_range(0.0..HEIGHT as f32),
            speed: rng.gen_range(20.0..100.0),
            twinkle_phase: rng.gen_range(0.0..std::f32::consts::TAU),
            twinkle_speed: rng.gen_range(1.0..3.0),
            depth: rng.gen_range(0.5..4.0),
        })
        .collect();

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
                    star.x -= star.speed * star.depth * dt;
                    if star.x < 0.0 {
                        star.x = WIDTH as f32;
                        star.y = rng.gen_range(0.0..HEIGHT as f32);
                        star.depth = rng.gen_range(0.5..4.0);
                        star.twinkle_phase = rng.gen_range(0.0..std::f32::consts::TAU);
                        star.twinkle_speed = rng.gen_range(1.0..3.0);
                    }

                    // Twinkle factor
                    let twinkle =
                        (elapsed * star.twinkle_speed + star.twinkle_phase).sin() * 0.5 + 0.5;
                    let intensity = (twinkle * 255.0 / star.depth).min(255.0) as u8;

                    // Color tint (fixed factor, avoids borrow checker issue)
                    let r = intensity;
                    let g = (intensity as f32 * 0.85) as u8;
                    let b = (intensity as f32 * 0.85) as u8;

                    // Draw a small STAR_SIZE x STAR_SIZE block
                    for dx in 0..STAR_SIZE {
                        for dy in 0..STAR_SIZE {
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
