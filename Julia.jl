# see https://hackernoon.com/julia-and-julia-sets-e5a6fa3de7a7 for parallel version
using Plots
function julia(x, y, width, height, c)
    # bit of trial and error here for the scale
    z = ((y/width)*2.7 - 1.3) + ((x/height)*4.5 - 2.5)im
    for i = 1:255
        z = z^2 + c
        if abs(z) >= 2
            return -i
        end
    end
    return 0
end


gr() #use gr backend but plots includes most popular plotting libraries

height = 1920
width = 1920

function julia_set(height, width, c)
    [julia(x, y, width, height, c) for x = 1:height, y = 1:width]
end

nr_frames = 600

e = 2.71828
c = 0.285+(0.005*im)  #different values of c here
#c = 0.7885e^(0*3.1415*im);
#c = -0.7269+(0.1889*im)
#This is where it gets different from hackernoon
dat = julia_set(height,width,c)

for i in 1:nr_frames
    #c = 0.7885e^((i/50)*3.1415*im) #set between 0 and 2pi
    c = 0.285+((0.005+(i*0.0002))*im)
    #step = i*0.001
    #c = -0.7269+((0.1889+step)*im)
    data = julia_set(height,width,c)
    global dat = cat(dat,data,dims=3)
    #println(i)  #im a debugging pro
end


println(size(dat))

file_name = "julia_set2.gif"
anim = @animate for i = 1:nr_frames #indexing starts at 1 for julia
    d = dat[:,:,i]
    axis=([], false)
    heatmap(d, size=(width,height), color=:darktest, leg=false, grid=false, showaxis=false)
    #try prism but that is quite intense
    println(i*100/nr_frames) #progress of render
end


gif(anim, file_name, fps=60)