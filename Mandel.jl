using Images, Colors, ColorSchemes, Random, BenchmarkTools, Base, Dates, CUDA, GPUArrays

##########
# iterations is the amount of times the formula will be run *over* itself
# fname can be changed to a string value "something" or leave it as a random string, your choices
########## 

function get_steps(c::Complex, iterations)
  z = Complex(0.0, 0.0)
  for i = 1:iterations
    z = z * z + c
    if abs(z) >= 2
      return i
    end
  end
  return iterations + 1
end

function get_color(colorscheme, step, iterations)
  if step == iterations+1
      return [0.0, 0.0, 0.0]
  end
  color = get(colorscheme, step, (1, iterations))
  return [color.r, color.g, color.b]
end

function get_cmap(cscheme, iterations)
  colors = zeros(Float64, (3, iterations+1))
  for i=1:iterations
    colors[:, i] = get_color(cscheme, i, iterations)
  end
  colors[:, iterations+1] = [0.0, 0.0, 0.0]
  return colors
end

function mandelbrot_plot(crmn=-2.5, crmx=1.5, cimn=-1.2, width=500, height=300, cscheme=ColorSchemes.inferno)
    
  _xby = "x"
  _by = "_"
  _randstr = randstring(6)
  fname = "$_randstr$_by$width$_xby$height$_by$crmn$crmx$cimn"

  w = width
  h = height

  println("===================================================================================================")
  println("Generating an image with dimensions $w$_xby$h, saving as '$fname.bmp' in 'img/$w$_xby$h/$fname.bmp'")  
  println("===================================================================================================")
  iterations = 5000
  # range for real vals
  # decreasing these numbers will zoom the rendered image in to the coordinates of the values, smaller = more zoom, larger = further apart
  # original values are cr_min = -2.5 cr_max = 1.5 ci_min = -1.2
  # CHANGES THE X [crmn-crmx]
  cr_min = crmn  # zoom 1 [+x]
  cr_max = crmx  # zoom 2 [-x]

  # CHANGES THE Y COORDINATE
  # range for imaginary vals
  # zoom control
  ci_min = cimn # [-y]

  range = cr_max - cr_min
  dot_size = range / w
  ci_max = ci_min + h * dot_size

  println("cr: $cr_min - $cr_max rng: ", cr_min - cr_max)
  println("ci: $ci_min - $ci_max rng: ", ci_min - ci_max)

  image = zeros(Float64, (3, h, w))

  complexes= zeros(ComplexF64, (h, w))

  steps = zeros(Int, (h, w))
  cu_steps = CuArray(zeros(Int, (h, w)))

  csc_sized = get_cmap(cscheme, iterations)

  x, y = 1, 1
  for ci = ci_min:dot_size:ci_max-dot_size
    x = 1
    for cr = cr_min:dot_size:cr_max-dot_size
      complexes[y, x] = Complex(cr, ci)
      x += 1
    end
    y += 1
  end

  cu_complexes = CuArray(complexes)

  cu_steps .= get_steps.(cu_complexes, iterations)

  synchronize()

  steps = Array(cu_steps)

  image = csc_sized[:, steps]
  
  println("===================================================================================================")
  println("Generated a $w$_xby$h image.")

  save("img/$w$_xby$h/$fname.bmp", colorview(RGB, image))  

  println("Saved file into 'img/$w$_xby$h/$fname.bmp'")
  println("===================================================================================================")

end



mandelbrot_plot(-0.2834, -0.6, 0.35 ,1500, 900, ColorSchemes.inferno)

# mandelbrot_plot(-2.5, -1.5, -1.2, 1000, 600, ColorSchemes.inferno)


###############################################################################################################################################
#
# EXAMPLE FUNCTION CALL 
# mandelbrot_plot([width], [height], ColorScheme.[somecolorscheme])
# 
# mandelbrot_plot(3840, 2160, ColorSchemes.inferno);       # KjoSgm
# mandelbrot_plot(3840, 2160, ColorSchemes.summer);        # njZLrZ
# mandelbrot_plot(3840, 2160, ColorSchemes.spring);        # BmyTdc
# mandelbrot_plot(3840, 2160, ColorSchemes.viridis);       # VESy4a
# mandelbrot_plot(3840, 2160, ColorSchemes.twilight);      # 9xiN6s
# mandelbrot_plot(3840, 2160, ColorSchemes.winter);        # PDx16A
# mandelbrot_plot(3840, 2160, ColorSchemes.nipy_spectral); # Yf6JJX
# mandelbrot_plot(3840, 2160, ColorSchemes.prism);         # wKXyWq
# mandelbrot_plot(3840, 2160, ColorSchemes.hot);           # rKhYB1

# mandelbrot_plot(1500, 900, ColorSchemes.inferno)

# -0.7491597623
# -0.7491597623 + 0.0000000004
# 0.1005089256

# mandelbrot_plot(-0.7491597623, -0.7491597623 + 0.0000000004, 0.1005089256, 3840, 2160, ColorSchemes.prism)
# mandelbrot_plot(-0.602500000000000000000000000009, -0.702500000000000000000000000009, -0.350000000000000000000000000009, 1500, 900, ColorSchemes.hot)
# mandelbrot_plot(-1.15, -1.1, -0.25, 3840, 2160, ColorSchemes.inferno)
# mandelbrot_plot(-1.1058045574565, -1.038571685831, -0.25, 3840, 2160, ColorSchemes.prism)

# SEE
# https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fi.stack.imgur.com%2FVzjiY.png&f=1&nofb=1
# this is the mandelbrot graph and if you correlate the range of cr as y and ci as x then you can kind-of plot it where you want it
