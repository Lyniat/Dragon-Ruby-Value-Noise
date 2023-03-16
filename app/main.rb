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

  noise = Noise.new(SEED + args.state.iteration)

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

        args.state.description = "value noise"

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

        args.state.description = "value noise"

        # cellular cell value as rgb color
      when 2
        noise.distance_function = Noise::CELLULAR_DISTANCE_FUNCTION_MANHATTAN
        noise.return_type = Noise::CELLULAR_RETURN_TYPE_CELL_VALUE
        noise.cellular_jitter = 1.0
        n = noise.get_cellular((x + OFFSET) * SCALE, (y + OFFSET) * SCALE)
        n = (n + 4) / 8 * 255 * 255 * 255
        args.pixel_array(:noise).pixels[y * SIZE + x] = 0xFF000000 + n.floor

        args.state.description = "cellular noise\ndistance: manhattan\nreturn type: distance\njitter: 1.0"

        # cellular distance, similar to water
      when 3
        noise.distance_function = Noise::CELLULAR_DISTANCE_FUNCTION_EUCLIDEAN
        noise.return_type = Noise::CELLULAR_RETURN_TYPE_DISTANCE
        noise.cellular_jitter = 1.0
        n = noise.get_cellular((x + OFFSET) * SCALE, (y + OFFSET) * SCALE)
        n = ((n + 1) * 127).floor
        r = n
        g = (n * 2)
        g = g > 255 ? 255 : g
        b = 255
        args.pixel_array(:noise).pixels[y * SIZE + x] = 0xFF000000 + r + (g << 8) + (b << 16)

        args.state.description = "cellular noise\ndistance: euclidean\nreturn type: distance\njitter: 1.0"

        # cellular distance, similar to water but with lower jitter
      when 4
        noise.distance_function = Noise::CELLULAR_DISTANCE_FUNCTION_EUCLIDEAN
        noise.return_type = Noise::CELLULAR_RETURN_TYPE_DISTANCE
        noise.cellular_jitter = 0.3
        n = noise.get_cellular((x + OFFSET) * SCALE, (y + OFFSET) * SCALE)
        n = ((n + 1) * 127).floor
        r = n
        g = (n * 2)
        g = g > 255 ? 255 : g
        b = 255
        args.pixel_array(:noise).pixels[y * SIZE + x] = 0xFF000000 + r + (g << 8) + (b << 16)

        args.state.description = "cellular noise\ndistance: euclidean\nreturn type: distance\njitter: 0.3"

        # grayscale cellular distance 2
      when 5
        noise.distance_function = Noise::CELLULAR_DISTANCE_FUNCTION_EUCLIDEAN
        noise.return_type = Noise::CELLULAR_RETURN_TYPE_DISTANCE_2
        noise.cellular_jitter = 0.8
        n = noise.get_cellular((x + OFFSET) * SCALE, (y + OFFSET) * SCALE)
        n = ((n + 1) * 127).floor
        r = 0
        g = n
        b = 255 - n
        args.pixel_array(:noise).pixels[y * SIZE + x] = 0xFF000000 + r + (g << 8) + (b << 16)

        args.state.description = "cellular noise\ndistance: euclidean\nreturn type: distance 2\njitter: 0.8"
      end
      y += 1
    end
    x += 1
  end

  args.state.iteration += 1
end

def tick args
  args.state.description ||= ""
  args.state.iteration ||= 0
  args.state.last_noise_mode ||= 0
  args.state.noise_mode ||= args.state.last_noise_mode

  args.state.noise_mode += 1 if args.inputs.keyboard.key_down.space
  args.state.noise_mode = 0 if args.state.noise_mode > 5

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
  labels = args.state.description.split("\n")
  labels.each_with_index do |l, i|
    args.outputs.labels << [0, HEIGHT - 30 - i * 30, l, 1, 0, 255, 0, 0]
  end
end
