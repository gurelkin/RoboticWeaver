import cv2
import numpy as np
from skimage.draw import line
from skimage.feature import blob_log
from skimage.transform import rescale
from skimage.io import imread
from skimage.util import crop

from utils import *


class Strand(object):
    """
    Represents one possible strand in a loom's image / canvas.
    """

    def __init__(self, nail1, nail2):
        nail1, nail2 = (nail1, nail2) if nail2 >= nail1 else (nail2, nail1)
        self.nails = (nail1, nail2)
        self.rows, self.cols = line(*nail1, *nail2)

    def get_line(self):
        return zip(self.rows, self.cols)


def adjust_image_size(image, resolution: int):
    height, width = image.shape[0], image.shape[1]
    scale_factor = resolution / height if height < width else resolution / width
    if len(image.shape) > 2:
        return np.array(WHITE * rescale(image, scale_factor, channel_axis=2), dtype=np.uint8)
    else:
        return rescale(image, scale_factor, preserve_range=True)


def adjust_image_dimensions(image, board_shape: tuple[int, int]):
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


def threshold_contrast(board, threshold, white=255):
    for i in range(len(board)):
        for j in range(len(board[i])):
            pxl = board[i][j]
            if pxl <= threshold:
                board[i][j] = 0
            else:
                board[i][j] = white
    return board


def choose_nails_locations(shape, n_nails):
    """
    Sets the location of `k` nails on the border of an image with `shape` dimensions.

    :param shape: Shape of the image.
    :param n_nails: Number of nails to be placed.
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
    gap = int(np.floor(perimeter / n_nails))
    chosen_indices = range(0, perimeter, gap)
    return [border_pixels[i] for i in chosen_indices]


def find_nails_locations(board, epsilon=7):
    """
    Detects the location of the nails on the board.

    :param epsilon: the maximum distance for blobs to be counted as the same nail.
    :param board: A grayscale (0-255) image of the nailed board.
    """
    # masking out everything outside the board
    mask = background_mask(board)
    mask = shrink_mask(mask, 16)
    mean = 0
    count = 0
    for i in range(len(mask)):
        for j in range(len(mask[i])):
            if mask[i][j]:
                mean += board[i][j]
                count += 1
    mean = mean / count
    board = np.where(mask, board, mean)

    # preprocessing
    normalized_negative = 1 - (board / WHITE)
    thresh = 1.5 * np.mean(normalized_negative)
    normalized_negative = threshold_contrast(normalized_negative, thresh, white=1)

    # find the nails in the image
    centers_sigmas = blob_log(normalized_negative)

    nails = [(int(c[0]), int(c[1])) for c in centers_sigmas]
    new_nails = []
    center_board = (board.shape[0] // 2, board.shape[1] // 2)
    nails = filter(lambda n: mask[n], nails)
    for nail in nails:
        good_nail = True
        for i in range(len(new_nails)):
            if np.math.dist(nail, new_nails[i]) < epsilon:
                # they are the same nail, probably
                # if np.math.dist(nail, center_board) > np.math.dist(center_board, new_nails[i]):
                #     new_nails[i] = nail
                good_nail = False
                break
        if good_nail:
            new_nails.append(nail)
    return new_nails


def get_all_possible_strands(nails_locations):
    """
    Generates a dict mapping from a nail to a list of all his possible strands.

    :param nails_locations: Indices of the nails on the image frame.
    :return: A dict mapping from a nail to a list of all his possible strands.
    """
    return {nail1: [Strand(nail1, nail2)
                    for nail2 in nails_locations
                    if nail2 != nail1]
            for nail1 in nails_locations}


def find_darkest_strand(image, possible_strands):
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


def coordify(board, anchors_xy=ANCHORS):
    # detect red anchors in the board image
    hsv = cv2.cvtColor(board, cv2.COLOR_RGB2HSV)
    mask1 = cv2.inRange(hsv, lower_red_1, upper_red_1)
    mask2 = cv2.inRange(hsv, lower_red_2, upper_red_2)
    mask = cv2.bitwise_or(mask1, mask2)
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    sorted_contours = sorted(contours, key=cv2.contourArea, reverse=True)[:4]
    anchors = [np.mean(contour, axis=0, dtype=int)[0] for contour in sorted_contours]
    # match every i-j anchor to its x-y coordinate
    anchors_ij = sorted(anchors, key=(lambda n: sum(n)))
    # create a homography between pixels and coordinates
    src_pts = np.array(anchors_ij[:3], dtype=np.float32)
    dst_pts = np.array(anchors_xy[:3], dtype=np.float32)
    matrix = cv2.getAffineTransform(src_pts, dst_pts)
    return lambda ij: matrix @ np.array([ij[1], ij[0], 1])


def background_mask(board):
    thresh = cv2.threshold(board, 80, 255, cv2.THRESH_BINARY)[1]
    thresh = thresh.astype(np.uint8)
    contours = cv2.findContours(thresh, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)[0]
    sorted_contours = sorted(contours, key=cv2.contourArea, reverse=True)
    cv2.drawContours(thresh, sorted_contours, 0, (255, 255, 255), cv2.FILLED)
    mask = np.where(thresh > 127, True, False)
    return mask


def shrink_mask(mask, n_iter):
    origin = mask
    def has_black_neighbor(i, j, mat):
        return not (np.all(mat[i-1:i+2, j-1:j+2]))

    for iter in range(n_iter):
        copy = origin.copy()
        for i in range(len(origin)):
            for j in range(len(origin[i])):
                if origin[i, j] and has_black_neighbor(i, j, origin):
                    copy[i, j] = False
        origin = copy
    return origin

class Loom(object):
    """
    Utility for approximating images using strands.
    """

    def __init__(self, image_path, board_path, intensity=INTENSITY):
        image = read_image(image_path, color=False)
        board = read_image(board_path, color=False)
        self.board = adjust_image_size(board, OPT_RES)
        self.image = adjust_image_dimensions(image, self.board.shape)
        self.canvas = WHITE * np.ones(self.board.shape, dtype=int)
        self.nails = find_nails_locations(self.board)
        self.strands = get_all_possible_strands(self.nails)
        board_rgb = read_image(board_path, color=True)
        board_rgb = adjust_image_size(board_rgb, OPT_RES)
        plot_image(board_rgb)
        self.nail2xy = coordify(board_rgb)
        self.intensity = int(np.floor(WHITE * intensity))
        self.initial_mean = np.mean(self.image)

    def weave(self, coordinates=False):
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
            current_nail = current_strand.nails[1] if current_strand.nails[1] != current_nail else current_strand.nails[
                0]
        if coordinates:
            return [self.nail2xy(n) for n in nails_sequence]
        return nails_sequence

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
            if num + 1 == number:
                location = nail
        plt.text(location[1], location[0], str(number + 1), fontsize=FONT_SIZE, color='red')
        plt.imshow(self.board, cmap='gray')
        plt.show()

    def plot_all_nail_numbers(self):
        for number, nail in enumerate(self.nails):
            plt.text(nail[1], nail[0], str(number + 1), fontsize=FONT_SIZE, color='red')
        plt.imshow(self.board, cmap='gray')
        plt.show()
