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
    locations = []
    # Set nails locations on the left and right of the images
    for i in range(0, rows, gap):
        locations.append((i, 0))
        locations.append((i, cols-1))
        k -= 2
    # Set nails locations on the top and bottom of the images
    for j in range(gap, cols, gap):
        locations.append((0, j))
        locations.append((rows-1, j))
        k -= 2
        if k == 0:
            break
    return set(locations)


