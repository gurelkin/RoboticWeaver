import math
from timeit import timeit
from time import time
import matplotlib.pyplot as plt
import numpy as np
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
    mona = read_image("Images/galileo.jpg")
    board = read_image("Images/smaller_shape_nail_frame.jpg")
    intensity = 0.1
    n_iter = 4000
    # loom = Loom(mona, board)
    loom = Loom(mona, board)
    loom.set_intensity(intensity)
    # start = time()
    print(f"Intensity = {intensity}")
    print(f"Number of iterations = {n_iter}")
    print(f"Number of nails = {len(loom.nails)}")
    plot_image(loom.image)
    print(f"Image shape = {loom.image.shape}, Canvas shape = {loom.canvas.shape}")
    loom.weave(n_iter)
    # print(f"time = {time() - start}")
    plot_image(loom.canvas)


def main_2():
    mona = read_image("Images/hendrix.jpg")
    intensity = 0.1
    n_iter = 5000
    n_nails = 200
    loom = Loom(mona, n_nails, (500, 250))
    loom.set_intensity(intensity)
    # start = time()
    print(f"Intensity = {intensity}")
    print(f"Number of iterations = {n_iter}")
    print(f"Number of nails = {len(loom.nails)}")
    loom.weave(n_iter)
    # print(f"time = {time() - start}")
    plot_image(loom.canvas)


def main_3():
    board = read_image("Images/uri.jpg")
    nails_i, nails_j = find_nails_locations_two_lists(board)
    out = WHITE*np.ones_like(board)
    out[nails_i, nails_j] = BLACK
    print(np.min(out), np.max(out))
    plot_image(out)


def main_4():
    mona = read_image("Images/MonaLisa.jpeg")
    board = read_image("Images/circular_nails_frame.jpg")
    adjusted = adjust_image_dimensions(mona, board.shape)
    print(adjusted)
    print(f"max = {np.max(adjusted)}, min = {np.min(adjusted)}")
    plot_image(adjusted)


def main_5():
    image = read_image("Images/MonaLisa.jpeg")
    board = read_image("Images/smaller_shape_nail_frame.jpg")
    loom = Loom(image, board)
    loom.plot_all_nail_numbers()


if __name__ == '__main__':
    main_5()
    # print(timeit(stmt='main()', setup='from __main__ import main', number=1))


