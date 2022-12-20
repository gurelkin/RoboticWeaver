import numpy as np
from skimage.draw import line, line_aa


def get_line(nail1: tuple[int, int], nail2: tuple[int, int]) -> dict[tuple[int, int], float]:
    """
    Returnes a dict that represents the line passing between two nails
    :param nail1: Nail with smaller index
    :param nail2: Nail with bigger index
    :return: A dict mapping indices to values
    """
    rows, cols, vals = line_aa(*nail1, *nail2)
    indices = [tuple(index) for index in zip(rows, cols)]
    return {indices[i]: vals[i] for i in range(len(indices))}


class Strand(object):
    """
    Represents one possible strand in the loom
    """
    def __init__(self, nail1, nail2):
        nail1, nail2 = (nail1, nail2) if nail2 >= nail1 else (nail2, nail1)
        self.nails = (nail1, nail2)
        self.line = get_line(nail1, nail2)


def choose_nails_locations(shape: tuple, k: int) -> list[tuple[int, int]]:
    """
    sets all the nails around the image
    :param shape: Shape of the image
    :param k: Number of nails to be placed
    :return: The indices of the nails' locations on the image
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


def get_all_possible_strands(nails_locations: list[tuple[int, int]]) -> dict[tuple[int, int], list[Strand]]:
    """
    :param nails_locations: Indices of the nails on the image frame
    :return: A dict mapping from a nail to all its possible strands
    """
    return {nail1: [Strand(nail1, nail2)
                    for nail2 in nails_locations
                    if nail2 != nail1]
            for nail1 in nails_locations}
    # return [Strand(nail1, nail2)
    #         for nail1 in nails_locations
    #         for nail2 in nails_locations
    #         if nail2 > nail1]


def find_darkest_line(image: np.array(list[list[float]]), possible_strands: list[Strand]) -> Strand:
    """
    :param image: The image to be scanned
    :param possible_strands: A list of all the lines in the image to check
    :return: The strand with the smallest mean value in its pixels
    """
    mean_values = [np.mean([image[index] * (1 - value) for index, value in strand.line.items()])
                   for strand in possible_strands]
    min_index = np.argmin(mean_values)
    return possible_strands[min_index]


class Loom(object):
    def __init__(self, image_: np.array(list[list[float]]), k_: int):
        self.image = image_.copy()
        self.canvas = np.ones(image_.shape)
        self.nails = choose_nails_locations(image_.shape, k_)
        self.strands = get_all_possible_strands(self.nails)

    def weave(self, bound, intensity=0.1):
        counter = 0
        current_nail = self.nails[0]
        while counter < bound:
            current_strand = find_darkest_line(self.image, self.strands[current_nail])
            for index, value in current_strand.line.items():
                print(index, "---", value)
                change = (1 - value)
                self.image[index] = min(1, self.image[index] + change)
                self.canvas[index] = max(0, self.canvas[index] - change)
            counter += 1
            current_nail = current_strand.nails[1] if current_strand.nails[1] != current_nail else current_strand.nails[0]
            # print("~~~", counter)
