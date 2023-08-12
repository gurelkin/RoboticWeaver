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
        return np.array(WHITE * rescale(image, scale_factor, channel_axis=2), dtype=int)
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
    normalized_negative = 1 - (board / 255)
    thresh = 1.5 * np.mean(normalized_negative)
    normalized_negative = threshold_contrast(normalized_negative, thresh, white=1)
    centers_sigmas = blob_log(normalized_negative)

    nails = [(int(c[0]), int(c[1])) for c in centers_sigmas]
    new_nails = []
    center_board = (board.shape[0] // 2, board.shape[1] // 2)
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


def coordify(board, nails, bases=BASE_NAILS_XY):
    # identify the base nails in the board RGB image
    def green_dist(idx):
        return np.linalg.norm(board[idx] - RGB_GREEN)
    base_nail_1, base_nail_2 = nails[:2]
    base_dist_1, base_dist_2 = green_dist(base_nail_1), green_dist(base_nail_2)
    for nail in nails[2:]:
        dist = green_dist(nail)
        if dist < base_dist_1:
            base_nail_2 = base_nail_1
            base_dist_2 = base_dist_1
            base_nail_1 = nail
            base_dist_1 = dist
        elif dist < base_dist_2:
            base_nail_2 = nail
            base_dist_2 = dist
    # define the ij->xy transformation
    if base_nail_1 > base_nail_2:
        base_xy_1, base_xy_2 = BASE_NAILS_XY
    else:
        base_xy_2, base_xy_1 = BASE_NAILS_XY
    pixel_x_length = abs(base_xy_1[0] - base_xy_2[0]) / abs(base_nail_1[0] - base_nail_2[0])
    pixel_y_length = abs(base_xy_1[1] - base_xy_2[1]) / abs(base_nail_1[1] - base_nail_2[1])
    def ij2xy(i, j):
        # TODO: abs() not working here, needs to find a way to tell if the x and y values are higher or lower than the base ones
        xy1 = (pixel_x_length * abs(base_nail_1[0] - i), pixel_y_length * abs(base_nail_1[1] - j))
        xy2 = (pixel_x_length * abs(base_nail_2[0] - i), pixel_y_length * abs(base_nail_2[1] - j))
        mean_xy = [round((xy1[0]+xy2[0])/2, 2), round((xy1[1]+xy2[1])/2, 2)]
        return mean_xy
    # map each nail to its (x, y) coordinate
    return {nail: ij2xy(*nail) for nail in nails}


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
        self.nail2xy = coordify(board_rgb, self.nails)
        self.intensity = int(np.floor(WHITE * intensity))
        self.initial_mean = np.mean(self.image)

    def weave(self):
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