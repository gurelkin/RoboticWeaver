import numpy as np
import matplotlib.pyplot as plt
import cv2
from skimage.feature import blob_log
from itertools import product

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


def set_nails_locations(board: Image, target_shape: tuple[Pixel]):
    """
    Returns the locations of the nails in the image as a list of pixels in a `target_shpe` canvas.
    :param board: Image of the nailed board.
    :param target_shape: Dimensions of the target image.
    :return:
    """
    def find_neighboring_pixels(pixel: Pixel) -> list[Pixel]:
        def bfs(current_pixel: Pixel, visited_black_pixels: list[Pixel]) -> None:
            def is_valid_index(indices: Pixel) -> bool:
                return 0 <= indices[0] <= mask.shape[0] and 0 <= indices[1] <= mask.shape[0]

            if not is_valid_index(current_pixel) or current_pixel in visited_black_pixels:
                return

            visited_black_pixels.append(current_pixel)

            for i, j in product((-1, 0, 1), (-1, 0, 1)):
                    if i != 0 or j != 0:
                        bfs((current_pixel[0] + i, current_pixel[1] + j), visited_black_pixels)

        list_of_neighbors: list[Pixel] = []
        bfs(pixel, list_of_neighbors)

        return list_of_neighbors

    def merge_neighboring_pixels(neighboring_pixels: list[Pixel], pixel_list: list[Pixel]):
        final_nails_locations.append(neighboring_pixels[0])
        pixel_list =  filter(lambda element : element not in neighboring_pixels, pixel_list)
        return pixel_list

    mask = np.where(board > GRAY, 1, 0)
    black_pixels = [(i, j) for i, j in np.ndindex(mask.shape) if mask[i][j] == 0]
    final_nails_locations = []
    for i, j in black_pixels:


def set_nails_locations(board: Image, target_shape: tuple[int, int]):
    blobs = blob_log(board)

def main_old():
    number_of_nails = 200
    intensity = 0.1
    number_of_iter = 6000
    mona = read_image("Images/mona_big.jpg")
    loom = Loom(mona, rectangle_nails_locations(mona.shape, number_of_nails))
    loom.set_intensity(intensity)
    print(loom.weave(number_of_iter))
    plt.title(f"{number_of_nails} nails, {number_of_iter} iterations, {intensity} intensity")
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