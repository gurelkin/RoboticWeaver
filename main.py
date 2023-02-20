from timeit import timeit
from time import time
import matplotlib.pyplot as plt
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
    plt.imshow(image, cmap='gray')
    plt.show()


def main():
    mona = read_image("Images/MonaLisa.jpeg")
    board = read_image("Images/circular_nails_frame.jpg")
    intensity = 0.1
    n_iter = 4000
    loom = Loom(mona, board)
    loom.set_intensity(intensity)
    # start = time()
    # plot_image(loom.image)
    loom.weave(n_iter)
    # print(f"time = {time() - start}")
    plot_image(loom.canvas)


def main1():
    board = read_image("Images/nails_frame.jpg")
    nails = find_nails_locations(board)
    locs = np.zeros_like(board)
    for (i, j) in nails:
        locs[i][j] = WHITE*10
    plot_image(locs)


if __name__ == '__main__':
    main()
    # print(timeit(stmt='main()', setup='from __main__ import main', number=1))


