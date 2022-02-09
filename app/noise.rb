# https://www.shadertoy.com/view/4dS3Wd

class Noise

  SIN = 0.479426 #sin(0.5)
  COS = 0.877582 #cos(0.5)

  def initialize(seed = 1337, octaves = 3)
    @seed = seed
    @octaves = octaves
  end

  def get(pos_x, pos_y) # fbm
    v = 0
    a = 0.5
    (0...@octaves).each do |i|
      v += a * noise(pos_x, pos_y)
      r_x, r_y = rotate(pos_x * 2, pos_y * 2)
      pos_x = r_x + 100
      pos_y = r_y + 100
      a *= 0.5
    end
    v
  end

  private

  def noise(x, y)
    i_x = x.floor
    i_y = y.floor
    f_x = fract(x)
    f_y = fract(y)

    # Four corners in 2D of a tile
    a = hash(i_x,i_y)
    b = hash(i_x + 1, i_y)
    c = hash(i_x, i_y + 1)
    d = hash(i_x + 1, i_y + 1)

    # Smooth Interpolation
    # Cubic Hermine Curve
    u_x = f_x**2 * (3 - 2 * f_x)
    u_y = f_y**2 * (3 - 2 * f_y)

    # Mix 4 corners percentages
    mix(a, b, u_x) + (c - a) * u_y * (1.0 - u_x) + (d - b) * u_x * u_y
  end

  def rotate(x, y)
    [COS * x + SIN * y, -SIN * x + COS * y]
  end

  def hash(x, y)
    p3_xz = fract(x * 0.13 * @seed)
    p3_y = fract(y * 0.13)
    d = vec3_dot(p3_xz,p3_y,p3_xz, p3_y + 3.333,p3_xz + 3.333, p3_xz + 3.333)
    q3_xz = p3_xz + d
    q3_y = p3_y + d
    fract((q3_xz + q3_y) * q3_xz)
  end

  def vec3_dot (ax, ay, az, bx ,by, bz)
    ax * bx + ay * by + az * bz
  end

  def fract(num)
    num - num.to_i
  end

  def mix(x, y, a)
    x * (1 - a) + y * a
  end
end
