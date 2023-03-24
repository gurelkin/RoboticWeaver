import numpy as np
import matplotlib.pyplot as plt
import cv2
from skimage.draw import line_aa

import preprocessing as pre
from loom import *


def read_image(path: str) -> Image:
    """
    Reads an image from `path`.

    :param path: Path to the image
    :return: A grayscale variant of the image as a 2d numpy array
    """
    image = cv2.imread(path)
    if len(image.shape) > 2:
        return cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
    return image


def plot_image(image: Image):
    """
    Plots `image` in grayscale.
    """
    plt.imshow(image, cmap='gray')
    plt.show()


def main_old():
    k_nails = 200
    intensity = 0.1
    n_iter = 6000
    mona = read_image("Images/MonaLisa.jpeg")
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


if __name__ == '__main__':
    main_old()