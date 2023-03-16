require 'app/noise.rb'

WIDTH = 1280
HEIGHT = 720
SIZE = 200
SEED = 0
SCALE = 0.07
OFFSET = -SIZE / 2
OCTAVES = 4

def generate_noise args
  args.pixel_array(:noise).width = SIZE
  args.pixel_array(:noise).height = SIZE

  noise = Noise.new(SEED + args.state.iteration, OCTAVES)

  x = 0
  while x < SIZE
    y = 0
    while y < SIZE
      case args.state.noise_mode
      when 0
        n = noise.get_fbm((x + OFFSET) * SCALE, (y + OFFSET) * SCALE)
        n = ((n + 1) * 127).floor
        args.pixel_array(:noise).pixels[y * SIZE + x] = 0xFF000000 + n + (n << 8) + (n << 16)
      when 1
        n = noise.get_cellular((x + OFFSET) * SCALE, (y + OFFSET) * SCALE)
        n = (n / 4) * 255 * 255 * 255
        args.pixel_array(:noise).pixels[y * SIZE + x] = 0xFF000000 + n.floor
      end
      y += 1
    end
    x += 1
  end

  args.state.iteration += 1
end

def tick args
  args.state.iteration ||= 0
  args.state.last_noise_mode ||= 0
  args.state.noise_mode ||= args.state.last_noise_mode

  args.state.noise_mode += 1 if args.inputs.keyboard.key_down.space
  args.state.noise_mode = 0 if args.state.noise_mode > 1

  generate_noise(args) if args.state.tick_count.zero? || args.state.noise_mode != args.state.last_noise_mode

  args.state.last_noise_mode = args.state.noise_mode

  args.outputs.sprites << {
    x: 0,
    y: 0,
    w: WIDTH,
    h: HEIGHT,
    path: :noise
  }

  args.outputs.labels << [0, HEIGHT, "PRESS SPACE TO CHANGE NOISE", 1, 0, 255, 0, 0]
end
