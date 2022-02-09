# frozen_string_literal: true

require 'app/noise.rb'

WIDTH = 1280
HEIGHT = 720
SIZE = 250
SEED = 5
SCALE = 0.1

def init args
  noise = Noise.new(SEED, 3)

  args.pixel_array(:noise).width = SIZE
  args.pixel_array(:noise).height = SIZE

  x = 0
  while x < SIZE
    y = 0
    while y < SIZE
      n = noise.get(x * SCALE, y * SCALE)
      n = (((n + 1) / 2) * 255).to_i
      args.pixel_array(:noise).pixels[y * SIZE + x] = 0xFF000000 + n + (n << 8) + (n << 16)
      y += 1
    end
    x += 1
  end
end

def tick args
  init(args) if args.state.tick_count.zero?

  args.outputs.primitives << [0, 0, WIDTH, HEIGHT, :noise].sprite
end
