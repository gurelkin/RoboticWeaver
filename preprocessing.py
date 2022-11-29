import numpy as np
import matplotlib.pyplot as plt
import cv2


def read_image(path: str) -> np.array:
    """
    :param path: Path to the image
    :return: A grayscale variant of the image as a 2d numpy array
    """
    image = cv2.imread(path)
    if len(image.shape) > 2:
        return cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
    return image


def nails_locations(shape: tuple, k: int) -> np.array:
    """
    :param shape: Shape of the image
    :param k: Number of nails to be placed
    :return: The indices of the nails' locations on the image
    """
    rows, cols = shape
    perimeter = 2*rows + 2*cols
    gap = int(np.floor(perimeter/k))
    # Put a nail in every corner
    locations = [(0, 0), (rows-1, 0), (0, cols-1), (rows-1, cols-1)]
    k -= 4
    # Set nails locations on the left and right of the images
    for i in range(gap, rows, gap):
        locations.append((i, 0))
        locations.append((i, cols-1))
        k -= 2
    # Set nails locations on the top and bottom of the images
    for j in reversed(range(gap, cols, gap)):
        locations.append((0, j))
        locations.append((rows-1, j))
        k -= 2
        if k == 0:
            break
    return set(locations)


def nails_locations_new(shape: tuple, k: int) -> list[tuple[int, int]]:
    """
    :param shape: Shape of the image
    :param k: Number of nails to be placed
    :return: The indices of the nails' locations on the image
    """
    rows, cols = shape
    border_pixels = []
    # Trace a continuous sequence of border pixels
    for i in range(rows-1):
        border_pixels.append((i, 0))
    for j in range(cols-1):
        border_pixels.append((rows-1, j))
    for i in reversed(range(1, rows)):
        border_pixels.append((i, cols-1))
    for j in reversed(range(1, cols)):
        border_pixels.append((0, j))
    # Find the gap between each nail and choose the pixels with this gap between them
    perimeter = len(border_pixels)
    gap = int(np.floor(perimeter / k))
    chosen_indices = range(0, perimeter, gap)
    return [border_pixels[i] for i in chosen_indices]

