import numpy as np
from skimage.draw import line
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


def rectangle_nails_locations(shape: tuple, k: int) -> list[Nail]:
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


def find_darkest_strand(image: Image, possible_strands: list[Strand]) -> Strand:
    """
    Finds the strand with the smallest (darkest) mean value in its pixels relative to `image`.

    :param image: The image to be scanned.
    :param possible_strands: A list of all the lines in the image to check.
    :return: The darkest strand in `possible_strands` relative to `image`.
    """
    # mean_values = [np.mean([image[index] for index in strand.line])
    #                for strand in possible_strands]
    # min_index = np.argmin(mean_values)
    min_index = 0
    min_mean = WHITE
    for i, strand in enumerate(possible_strands):
        curr_mean = np.mean(image[strand.rows, strand.cols])
        if curr_mean < min_mean:
            min_mean = curr_mean
            min_index = i
    return possible_strands[min_index]


class Loom(object):
    """
    Utility for approximating images using strands.
    """
    def __init__(self, image_: Image, nails_: list[Nail]):
        self.image = image_.copy()
        self.canvas = WHITE * np.ones(image_.shape, dtype=int)
        self.nails = nails_
        self.strands = get_all_possible_strands(self.nails)
        self.intensity = int(np.floor(WHITE * 0.1))

    def set_intensity(self, new_intensity: float):
        """
        Set the intensity of the loom's strands.

        :param new_intensity: A value between 0 and 1.
        """
        if 0 <= new_intensity <= 1:
            self.intensity = int(np.floor(WHITE * new_intensity))
        else:
            print(f"Invalid intensity: `{new_intensity}` is not between 0 and 1")

    def weave(self, bound: int) -> list[Nail]:
        """
        Weaves onto `self.canvas` a strand-approximation of `self.image`.

        :param bound: Number of weave iterations to be done.
        :return: A list of nails that were used in the weaving in order of usage.
        """
        counter = 0
        current_nail = self.nails[0]
        nails_sequence = []
        while counter < bound:
            print(f"{counter}/{bound}")
            # Find the darkest strand relative to `self.image`,
            # remove its intensity from `self.canvas` and add its intensity to `self.image1
            current_strand = find_darkest_strand(self.image, self.strands[current_nail])
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
