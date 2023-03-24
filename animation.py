import random

import matplotlib.animation as animation
import matplotlib.pyplot as plt
import numpy as np
import random
from loom import choose_nails_locations

shape = (100, 100)
nails = choose_nails_locations(shape, 200)

def make_random_weaving(num_iter):
    out = []
    current_nail = nails[0]
    for i in range(num_iter):
        next_nail = random.choice(nails)
        while next_nail == current_nail:
            next_nail = random.choice(nails)
        out.append((current_nail, next_nail))
        current_nail = next_nail
    return out

# creating a blank window
# for the animation
fig = plt.figure()
axis = plt.axes(xlim=(0, shape[0]),
                ylim=(0, shape[1]))

line, = axis.plot([], [], lw=1)


# what will our line dataset contain?
def init():
    line.set_data([], [])
    return line,


# initializing empty values
# for x and y co-ordinates
xdata, ydata = [], []


# animation function
def animate(i):
    # t is a parameter which varies
    # with the frame number
    t = 0.1 * i

    # x, y values to be plotted
    x = t * np.sin(t)
    y = t * np.cos(t)

    # appending values to the previously
    # empty x and y data holders
    xdata.append(x)
    ydata.append(y)
    line.set_data(xdata, ydata)

    return line,


# calling the animation function
anim = animation.FuncAnimation(fig, animate, init_func=init,
                               frames=500, interval=20, blit=True)

# saves the animation in our desktop
anim.save('growingCoil.mp4', writer='ffmpeg', fps=30)