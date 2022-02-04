using Images, Colors, ColorSchemes, Random

function get_steps(c::Complex, max_steps)
  z = Complex(0.0, 0.0)
  for i = 1:max_steps
    z = z * z + c
    if abs(z) >= 2
      return i
    end
  end
  return max_steps + 1
end

function get_color(colorscheme, step, max_steps)
  if step == max_steps+1
      return [0.0, 0.0, 0.0]
  end
  color = get(colorscheme, step, (1, max_steps))
  return [color.r, color.g, color.b]
end

function mandelbrot_plot(width, height, cscheme)
  w = width
  h = height

  max_steps = 500
  steps = zeros(Int, (h, w))

  #range for real vals
  cr_min = -2
  cr_max = 2

  #ramge for imaginary vals
  ci_min = -1.2

  range = cr_max - cr_min
  dot_size = range / w
  ci_max = ci_min + h * dot_size

  println("cr: $cr_min - $cr_max")
  println("ci: $ci_min - $ci_max")

  fname = randstring(6)

  image = zeros(Float64, (3, h, w))
  x, y = 1, 1
  for ci = ci_min:dot_size:ci_max-dot_size
    x = 1
    for cr = cr_min:dot_size:cr_max-dot_size
      c = Complex(cr, ci)
      gclr = get_color(cscheme, get_steps(c, max_steps), max_steps)
      image[:, y, x] = gclr
      println("($x,$y) : $fname.bmp : COLOR : $gclr")
      x += 1
    end
    y += 1
    println("($x,$y) : $fname.bmp")
  end

  println("======================================")
  println("Generated a $w$xby$h image using $cscheme as the color scheme. ")

  xby = "x"
  save("img/$w$xby$h/$fname.bmp", colorview(RGB, image))
end

# mandelbrot_plot(3840, 2160, ColorSchemes.inferno);       # KjoSgm
# mandelbrot_plot(3840, 2160, ColorSchemes.summer);        # njZLrZ
# mandelbrot_plot(3840, 2160, ColorSchemes.spring);        # BmyTdc
# mandelbrot_plot(3840, 2160, ColorSchemes.viridis);       # VESy4a
# mandelbrot_plot(3840, 2160, ColorSchemes.twilight);      # 9xiN6s
# mandelbrot_plot(3840, 2160, ColorSchemes.winter);        # PDx16A
# mandelbrot_plot(3840, 2160, ColorSchemes.nipy_spectral); # Yf6JJX
# mandelbrot_plot(3840, 2160, ColorSchemes.prism);         # wKXyWq
# mandelbrot_plot(3840, 2160, ColorSchemes.hot);           # rKhYB1

mandelbrot_plot(1000, 600, ColorSchemes.hot);
