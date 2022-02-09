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
      result = rotate(pos_x * 2, pos_y * 2)
      pos_x = result.x + 100
      pos_y = result.y + 100
      a *= 0.5
    end
    v
  end

  private

  def noise(x, y)
    st = {x: x, y: y}
    i = {x: st.x.floor, y: st.y.floor}
    f = {x: fract(st.x), y: fract(st.y)}

    # Four corners in 2D of a tile
    vec_b = {x: 1 + i.x, y: i.y}
    vec_c = {x: i.x,y: i.y + 1}
    vec_d = {x: i.x + 1,y: i.y + 1}
    a = hash(i)
    b = hash(vec_b)
    c = hash(vec_c)
    d = hash(vec_d)

    # Smooth Interpolation
    # Cubic Hermine Curve
    u = {x: f.x**2 * (3 - 2 * f.x),y: f.y**2 * (3 - 2 * f.y)}

    # Mix 4 corners percentages
    mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y
  end

  def rotate(x, y)
    {x: COS * x + SIN * y, y: -SIN * x + COS * y}
  end

  def hash(p)
    p3 = {x: fract(p.x * 0.13 * @seed),y: fract(p.y * 0.13),z: fract(p.x * 0.13)}
    d = vec3_dot(p3, {x: p3.y + 3.333,y: p3.z + 3.333,z: p3.x + 3.333})
    q3 = {x: p3.x + d,y: p3.y + d,z: p3.z + d}
    fract((q3.x + q3.y) * q3.z)
  end

  def vec3_dot vec_a, vec_b
    vec_a.x * vec_b.x + vec_a.y * vec_b.y + vec_a.z * vec_b.z
  end

  def fract(num)
    num - num.to_i
  end

  def mix(x, y, a)
    x * (1 - a) + y * a
  end
end
