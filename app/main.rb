require 'app/noise.rb'

WIDTH = 1280
HEIGHT = 720
SIZE = 200
SEED = 3
SCALE = 0.07
OFFSET = -SIZE / 2
OCTAVES = 8

def init args
  noise = Noise.new(SEED, OCTAVES)

  args.pixel_array(:noise).width = SIZE
  args.pixel_array(:noise).height = SIZE

  x = 0
  while x < SIZE
    y = 0
    while y < SIZE
      n = noise.get((x + OFFSET) * SCALE, (y + OFFSET) * SCALE)
      n = ((n + 1) * 127).floor
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
