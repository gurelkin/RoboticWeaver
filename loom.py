from skimage.draw import line
from skimage.feature import blob_log
from skimage.transform import rescale
from skimage.util import crop
import matplotlib.pyplot as plt
from names import *


class Strand(object):
    """
    Represents one possible strand in a loom's image / canvas.
    """

    def __init__(self, nail1: Nail, nail2: Nail):
        nail1, nail2 = (nail1, nail2) if nail2 >= nail1 else (nail2, nail1)
        self.nails = (nail1, nail2)
        self.rows, self.cols = line(*nail1, *nail2)

    def get_line(self):
        return zip(self.rows, self.cols)


def adjust_image_size(image: Image, resolution: int) -> Image:
    height, width = image.shape
    scale_factor = resolution / height if height < width else resolution / width
    return rescale(image, scale_factor, preserve_range=True)


def adjust_image_dimensions(image: Image, board_shape: tuple[int, int]) -> Image:
    """
    Adjusts `image` to fit `board_shape`.
    If the image proportions do not match `board_shape`, the largest middle part of the image will be cropped.

    :param image: The image to be reshaped
    :param board_shape: The desired shape
    """
    image_height, image_width = image.shape
    board_height, board_width = board_shape
    scale_factor = board_height / image_height if image_height < image_width else board_width / image_width
    rescaled_image = rescale(image, scale_factor, preserve_range=True)
    image_height, image_width = rescaled_image.shape
    height_crop = (image_height - board_height) // 2
    width_crop = (image_width - board_width) // 2
    cropped = crop(rescaled_image, ((height_crop, height_crop), (width_crop, width_crop)))
    return np.array(cropped.tolist(), dtype=int)


def choose_nails_locations(shape: tuple, k: int) -> list[Nail]:
    """
    Sets the location of `k` nails on the border of an image with `shape` dimensions.

    :param shape: Shape of the image.
    :param k: Number of nails to be placed.
    :return: The indices of the nails' locations on the image.
    """
    rows, cols = shape
    border_pixels = []
    # Trace a continuous sequence of border pixels
    for i in range(rows - 1):
        border_pixels.append((i, 0))
    for j in range(cols - 1):
        border_pixels.append((rows - 1, j))
    for i in reversed(range(1, rows)):
        border_pixels.append((i, cols - 1))
    for j in reversed(range(1, cols)):
        border_pixels.append((0, j))
    # Find the gap between each nail and choose the pixels with this gap between them
    perimeter = len(border_pixels)
    gap = int(np.floor(perimeter / k))
    chosen_indices = range(0, perimeter, gap)
    return [border_pixels[i] for i in chosen_indices]


def find_nails_locations(board: Image, epsilon=7) -> list[Nail]:
    """
    Detects the location of the nails on the board.

    :param epsilon: the maximum distance for blobs to be counted as the same nail.
    :param board: A grayscale (0-255) image of the nailed board.
    """
    normalized_negative = 1-(board/WHITE)
    centers_sigmas = blob_log(normalized_negative)
    nails = [(int(c[0]), int(c[1])) for c in centers_sigmas]
    new_nails = []
    for nail in nails:
        good_nail = True
        for nn in new_nails:
            if np.math.dist(nail, nn) < epsilon:
                # they are the same nail, probably
                good_nail = False
                break
        if good_nail:
            new_nails.append(nail)
    return new_nails


def get_all_possible_strands(nails_locations: list[Nail]) -> dict[Nail, list[Strand]]:
    """
    Generates a dict mapping from a nail to a list of all his possible strands.

    :param nails_locations: Indices of the nails on the image frame.
    :return: A dict mapping from a nail to a list of all his possible strands.
    """
    return {nail1: [Strand(nail1, nail2)
                    for nail2 in nails_locations
                    if nail2 != nail1]
            for nail1 in nails_locations}


def find_darkest_strand(image: Image, possible_strands: list[Strand]) -> tuple[Strand, float]:
    """
    Finds the strand with the smallest (darkest) mean value in its pixels relative to `image`.

    :param image: The image to be scanned.
    :param possible_strands: A list of all the lines in the image to check.
    :return: The darkest strand in `possible_strands` relative to `image`.
    """
    min_index = 0
    min_mean = WHITE
    for i, strand in enumerate(possible_strands):
        curr_mean = np.mean(image[strand.rows, strand.cols])
        if curr_mean < min_mean:
            min_mean = curr_mean
            min_index = i
    return possible_strands[min_index], min_mean


class Loom(object):
    """
    Utility for approximating images using strands.
    """

    def __init__(self, image_: Image, board_: Image, intensity=INTENSITY):
        self.board = adjust_image_size(board_, OPT_RES)
        self.image = adjust_image_dimensions(image_, self.board.shape)
        self.canvas = WHITE * np.ones(self.board.shape, dtype=int)
        self.nails = find_nails_locations(self.board)
        self.strands = get_all_possible_strands(self.nails)
        self.intensity = int(np.floor(WHITE * intensity))
        self.initial_mean = np.mean(self.image)

    def weave(self) -> list[Nail]:
        """
        Weaves onto `self.canvas` a strand-approximation of `self.image`.

        :return: A list of nails that were used in the weaving in order of usage.
        """
        counter = 0
        current_nail = self.nails[0]
        nails_sequence = []
        current_mean = 0
        while current_mean < TARGET_BRIGHTNESS:
            print(f"iter {counter}")
            # Find the darkest strand relative to `self.image`
            # remove its intensity from `self.canvas` and add its intensity to `self.image`
            current_strand, current_mean = find_darkest_strand(self.image, self.strands[current_nail])
            for pixel in current_strand.get_line():
                self.image[pixel] = min(WHITE, self.image[pixel] + self.intensity)
                self.canvas[pixel] = max(BLACK, self.canvas[pixel] - self.intensity)
            counter += 1
            # Add the used nail to the nails sequence
            nails_sequence.append(current_nail)
            current_nail = current_strand.nails[1] if current_strand.nails[1] != current_nail else current_strand.nails[0]
        return nails_sequence

    def reset(self, new_image: Image, new_k: int):
        """
        Resets the loom with a new image.

        :param new_image: The new image to be woven.
        :param new_k: Number of nails to be placed.
        """
        self.image = new_image.copy()
        self.canvas = WHITE * np.ones(new_image.shape, dtype=int)
        self.nails = choose_nails_locations(new_image.shape, new_k)
        self.strands = get_all_possible_strands(self.nails)

    def plot_nail_number(self, location):
        number = -1
        for num, nail in enumerate(self.nails):
            if nail == location:
                number = num
        plt.text(location[1], location[0], str(number + 1), fontsize=FONT_SIZE, color='red')
        plt.imshow(self.board, cmap='gray')
        plt.show()

    def plot_nail_location(self, number):
        location = (-1, -1)
        for num, nail in enumerate(self.nails):
            if num+1 == number:
                location = nail
        plt.text(location[1], location[0], str(number + 1), fontsize=FONT_SIZE, color='red')
        plt.imshow(self.board, cmap='gray')
        plt.show()

    def plot_all_nail_numbers(self):
        for number, nail in enumerate(self.nails):
            plt.text(nail[1], nail[0], str(number+1), fontsize=FONT_SIZE, color='red')
        plt.imshow(self.board, cmap='gray')
        plt.show()
