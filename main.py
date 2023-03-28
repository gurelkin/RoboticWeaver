import math
from timeit import timeit
from time import time
import matplotlib.pyplot as plt
import numpy as np
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
    mona = read_image("Images/MonaLisa.jpeg")
    board = read_image("Images/smaller_shape_nail_frame.jpg")
    intensity = 0.15
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


def main_2():
    mona = read_image("Images/hendrix.jpg")
    intensity = 0.1
    n_iter = 6000
    mona = read_image("Images/mona_big.jpg")
    loom = Loom(mona, k_nails)
    loom.set_intensity(intensity)
    print(loom.weave(n_iter))
    plt.title(f"{k_nails} nails, {n_iter} iterations, {intensity} intensity")
    plot_image(loom.canvas)
    # plot_image(loom.image)

    # mona = pre.read_image("images/MonaLisa.jpeg")
    # uri = pre.read_image("images/uri.jpg")
    # IMG = mona
    # loom = Loom(IMG, 200)
    # loom.weave(4000, intensity=50)
    #
    # plt.imshow(loom.canvas, cmap='gray')
    # plt.show()


def main_anim():
    k_nails = 200
    intensity = 0.2
    n_iter = 1300
    # mona = read_image("Images/MonaLisa.jpeg")
    mona = read_image("Images/jimmy.jpg")
    loom = Loom(mona, k_nails)
    loom.set_intensity(intensity)
    weaving = loom.weave(n_iter)
    # plt.title(f"{k_nails} nails, {n_iter} iterations, {intensity} intensity")
    # plot_image(loom.canvas)
    anim = Animator(weaving, loom.canvas.shape, loom.nails, n_iter, intensity, FPS=100)
    anim.animate()


if __name__ == '__main__':
    main_anim()
