import math
from timeit import timeit
from time import time

import cv2
import matplotlib.pyplot as plt
import numpy as np
import skimage

from animation import Animator
from skimage.io import imread
from loom import *


def read_image(path: str) -> Image:
    """
    Reads an image from `path`.

    :param path: Path to the image
    :return: A grayscale variant of the image as a 2d numpy array
    """
    return np.array(WHITE*imread(path, as_gray=True), dtype=int)


def plot_image(image: Image):
    """
    Plots `image` in grayscale.
    """
    plt.imshow(image, cmap='gray', vmin=BLACK, vmax=WHITE)
    plt.show()


def main_1():
    mona = read_image("Images/hendrix.jpg")
    board = read_image("Images/nails_square.jpg")
    intensity = 0.12
    n_iter = 2000
    # loom = Loom(mona, board)
    loom = Loom(mona, board)
    loom.set_intensity(intensity)
    # start = time()
    print(f"Intensity = {intensity}")
    print(f"Number of iterations = {n_iter}")
    print(f"Number of nails = {len(loom.nails)}")
    print(f"Image shape = {loom.image.shape}, Canvas shape = {loom.canvas.shape}")
    print(f"Initial brightness = {loom.initial_mean}")
    loom.weave()
    # print(f"time = {time() - start}")
    plot_image(loom.canvas)


def main_anim():
    mona = read_image("Images/MonaLisa.jpeg")
    board = read_image("Images/nails_polygon.jpg")
    intensity = 0.15
    n_iter = 2000
    # loom = Loom(mona, board)
    loom = Loom(mona, board)
    loom.set_intensity(intensity)
    weaving = loom.weave()
    # plt.title(f"{k_nails} nails, {n_iter} iterations, {intensity} intensity")
    # plot_image(loom.canvas)
    anim = Animator(weaving, loom.canvas.shape, loom.nails, n_iter, intensity, FPS=100)
    anim.animate()


def main_cap():
    mona = read_image("Images/MonaLisa.jpeg")
    board = read_image("captured.png")
    negative = 255 - board
    negative = skimage.filters.gaussian(negative,
                                        sigma=1,
                                        preserve_range=True)
    for i in range(len(negative)):
        for j in range(len(negative[i])):
            pxl = negative[i][j]
            if pxl < 140:
                negative[i][j] = 0
    plot_image(negative)
    # loom = Loom(mona, board)
    # print(loom.nails)
    # negative = skimage.filters.gaussian(negative,
    #                                     sigma=1,
    #                                     preserve_range=True)
    # plot_image(negative)
    plt.imshow(board)
    bl = blob_log(negative/255)
    nails = [(int(c[0]), int(c[1])) for c in bl]
    plt.scatter([n[1] for n in nails],
                [n[0] for n in nails])
    plt.show()
    print(nails)
    # print(blob_log(negative/255))


if __name__ == '__main__':
    main_cap()
