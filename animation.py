import random
import pygame
import matplotlib.animation as animation
import matplotlib.pyplot as plt
import numpy as np
import random
from loom import choose_nails_locations

pygame.init()
WHITE = (255, 255, 255)

clock = pygame.time.Clock()


def make_random_weaving(num_iter, nails):
    out = []
    current_nail = nails[0]
    for i in range(num_iter):
        next_nail = random.choice(nails)
        while next_nail == current_nail:
            next_nail = random.choice(nails)
        out.append((current_nail, next_nail))
        current_nail = next_nail
    return out


class Animator:
    def __init__(self, weaving, shape, nails, num_iter, intensity, FPS=30):
        """
        a class used to animate weaving using pygame
        :param weaving: a list of weavings (pairs of nails locations)
        :param shape: the size of the canvas
        :param nails: a set of nails locations
        :param num_iter: number of iterations
        :param intensity: line color intensity
        """
        self.weaving = weaving
        self.nails = nails
        self.shape = (shape[1], shape[0])
        self.num_iter = num_iter
        self.line_color = (0, 0, 0, 255 * intensity)
        self.screen = pygame.display.set_mode(shape)
        self.fps = FPS

    def animate(self):
        self.screen.fill(WHITE)
        running = True
        index = 0
        while running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False

            if index <= len(self.weaving) - 2:
                surf = pygame.Surface(self.screen.get_size(), pygame.SRCALPHA)
                start_pos = (self.weaving[index][1], self.weaving[index][0])
                end_pos = (self.weaving[index + 1][1], self.weaving[index + 1][0])
                pygame.draw.line(surf, self.line_color, start_pos, end_pos)
                self.screen.blit(surf, (0, 0))
                pygame.display.flip()
                index += 1
                clock.tick(self.fps)
        pygame.quit()


def main():
    intensity = 0.2
    shape = (800, 800)
    nails = choose_nails_locations(shape, 200)
    num_iter = 1000
    weaving = make_random_weaving(num_iter, nails)
    # might need to reverse this
    anim = Animator(weaving, shape, nails, num_iter, intensity)
    anim.animate()


if __name__ == "__main__":
    main()

#
# # creating a blank window
# # for the animation
# fig = plt.figure()
# axis = plt.axes(xlim=(0, shape[0]),
#                 ylim=(0, shape[1]))
#
# line, = axis.plot([], [], lw=1)
#
#
# # what will our line dataset contain?
# def init():
#     line.set_data([], [])
#     return line,
#
#
# # initializing empty values
# # for x and y co-ordinates
# xdata, ydata = [], []
#
#
# # animation function
# def animate(i):
#     # t is a parameter which varies
#     # with the frame number
#     t = 0.1 * i
#
#     # x, y values to be plotted
#     x = t * np.sin(t)
#     y = t * np.cos(t)
#
#     # appending values to the previously
#     # empty x and y data holders
#     xdata.append(x)
#     ydata.append(y)
#     line.set_data(xdata, ydata)
#
#     return line,
#
#
# # calling the animation function
# anim = animation.FuncAnimation(fig, animate, init_func=init,
#                                frames=500, interval=20, blit=True)
#
# # saves the animation in our desktop
# anim.save('growingCoil.mp4', writer='ffmpeg', fps=30)
