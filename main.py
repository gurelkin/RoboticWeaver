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
import sys


def read_image(path: str) -> Image:
    """
    Reads an image from `path`.

    :param path: Path to the image
    :return: A grayscale variant of the image as a 2d numpy array
    """
    return np.array(WHITE * imread(path, as_gray=True), dtype=int)


def plot_image(image: Image):
    """
    Plots `image` in grayscale.
    """
    plt.imshow(image, cmap='gray', vmin=BLACK, vmax=WHITE)
    plt.show()


def save_plot_image(image: Image, path: str):
    """
    Plots `image` in grayscale.
    """
    plt.imshow(image, cmap='gray', vmin=BLACK, vmax=WHITE)
    plt.savefig(path)


def write_nails_to_file(nails, path, image_height):
    with open(path, "w") as f:
        for y, x in nails:
            y = image_height - y
            f.write(f"{x} {y}\n")


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





def main(*args, **kwargs):
    if len(sys.argv) != 3:
        print("Usage: main.py <image path> <nails image path>")
    image_path = sys.argv[1]
    nails_path = sys.argv[2]
    image = read_image(image_path)
    board = read_image(nails_path)
    intensity = 0.12
    # loom = Loom(mona, board)
    loom = Loom(image, board)
    loom.set_intensity(intensity)
    nail_sequence = loom.weave()
    save_plot_image(loom.canvas, image_path + "_result.png")
    write_nails_to_file(nail_sequence, image_path + "_sequence.ssc", len(image))
    print("Done.")


if __name__ == '__main__':
    main()
