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

  # some colors are taken from https://en.wikipedia.org/wiki/PICO-8

  x = 0
  while x < SIZE
    y = 0
    while y < SIZE
      case args.state.noise_mode
        # simple grayscale fbm noise
      when 0
        n = noise.get_fbm((x + OFFSET) * SCALE, (y + OFFSET) * SCALE)
        n = ((n + 1) * 127).floor
        args.pixel_array(:noise).pixels[y * SIZE + x] = 0xFF000000 + n + (n << 8) + (n << 16)

        # fbm noise seperated into three colors
      when 1
        n = noise.get_fbm((x + OFFSET) * SCALE, (y + OFFSET) * SCALE)
        n = ((n + 1) * 127).floor
        # #29adff Cyan
        if n < 120
          r = 0x29
          g = 0xAD
          b = 0xFF
        # #008751 Dark Green
        elsif n < 180
          r = 0x00
          g = 0x87
          b = 0x51
        # #5f574f Dark Gray
        else
          r = 0x5F
          g = 0x57
          b = 0x4F
        end
        args.pixel_array(:noise).pixels[y * SIZE + x] = 0xFF000000 + r + (g << 8) + (b << 16)

        # cellular cell value as rgb color
      when 2
        n = noise.get_cellular((x + OFFSET) * SCALE, (y + OFFSET) * SCALE)
        n = (n + 4) / 8 * 255 * 255 * 255
        args.pixel_array(:noise).pixels[y * SIZE + x] = 0xFF000000 + n.floor

        # cellular distance, similar to water
      when 3
        n = noise.get_cellular((x + OFFSET) * SCALE, (y + OFFSET) * SCALE, Noise::CELLULAR_RETURN_TYPE_DISTANCE)
        n = ((n + 1) * 127).floor
        r = n
        g = (n * 2)
        g = g > 255 ? 255 : g
        b = 255
        args.pixel_array(:noise).pixels[y * SIZE + x] = 0xFF000000 + r + (g << 8) + (b << 16)

        # grayscale cellular distance 2
      when 4
        n = noise.get_cellular((x + OFFSET) * SCALE, (y + OFFSET) * SCALE, Noise::CELLULAR_RETURN_TYPE_DISTANCE_2)
        n = ((n + 1) * 127).floor
        args.pixel_array(:noise).pixels[y * SIZE + x] = 0xFF000000 + n + (n << 8) + (n << 16)
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
  args.state.noise_mode = 0 if args.state.noise_mode > 4

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
