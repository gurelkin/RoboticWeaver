import matplotlib.pyplot as plt
from skimage.io import imread
from skimage.filters import gaussian
from skimage.feature import blob_log
import sys
from animation import Animator
from loom import Loom
from names import *


def read_image(path: str) -> Image:
    """
    Reads an image from `path`.

    :param path: Path to the image
    :return: A grayscale variant of the image as a 2d numpy array
    """
    return np.array(WHITE * imread(path, as_gray=True), dtype=int)


def plot_image(image: Image):
    """
    Plots `image` in grayscale.
    """
    plt.imshow(image, cmap='gray', vmin=BLACK, vmax=WHITE)
    plt.show()


def save_image(image: Image, path: str):
    """
    Saves `image` in the requested `path`.
    """
    plt.imshow(image, cmap='gray', vmin=BLACK, vmax=WHITE)
    plt.savefig(path)


def threshold_contrast(board, threshold):
    for i in range(len(board)):
        for j in range(len(board[i])):
            pxl = board[i][j]
            if pxl <= threshold:
                board[i][j] = 0
            else:
                board[i][j] = 255
    return board


def nail_coordinates(nails_list, z_camera, image_shape, focal_length=1):
    image_center_x, image_center_y = image_shape[:2] / 2

    # Calculate the coordinates for each pixel in the list
    coordinates = []
    for nail in nails_list:
        x_nail, y_nail = nail
        x = (x_nail - image_center_x) * (z_camera / focal_length)
        y = (y_nail - image_center_y) * (z_camera / focal_length)

        coordinates.append((x, y))

    return coordinates


def write_nails_to_file(nails, path, image_height):
    with open(path, "w") as f:
        for y, x in nails:
            y = image_height - y
            f.write(f"{x} {y}\n")


def main_anim():
    image = read_image("images/dbg.jpg")
    board = read_image("frames/nails_polygon.jpg")
    intensity = 0.15
    loom = Loom(image, board, intensity=intensity)
    weaving = loom.weave()
    anim = Animator(weaving, loom.canvas.shape, loom.nails, intensity)
    anim.animate(make_video=True, video_name="video")


def main_cap():
    mona = read_image("images/MonaLisa.jpeg")
    board = read_image("captured.png")
    THRESH = 140
    negative = 255 - board
    negative = gaussian(negative, sigma=1, preserve_range=True)
    thresh = 1.6 * np.math.floor(np.mean(negative))
    negative = threshold_contrast(negative, thresh)
    plot_image(negative)
    # loom = Loom(mona, board)
    # print(loom.nails)
    # negative = skimage.filters.gaussian(negative,
    #                                     sigma=1,
    #                                     preserve_range=True)
    # plot_image(negative)
    plt.imshow(board)
    bl = blob_log(negative / 255)
    nails = [(int(c[0]), int(c[1])) for c in bl]

    print(nails)
    new_nails = []
    epsilon = 7
    for nail in nails:
        good_nail = True
        for nn in new_nails:
            if np.math.dist(nail, nn) < epsilon:
                # they are the same nail, probably
                good_nail = False
                break
        if good_nail:
            new_nails.append(nail)
    print(new_nails)
    plt.scatter([n[1] for n in new_nails],
                [n[0] for n in new_nails])
    plt.show()


def main(*args, **kwargs):
    if len(sys.argv) != 3:
        print("Usage: main.py <image path> <nail frame path>")
    image_path = sys.argv[1]
    nails_path = sys.argv[2]
    image = read_image(image_path)
    board = read_image(nails_path)
    loom = Loom(image, board)
    nail_sequence = loom.weave()
    save_image(loom.canvas, image_path + "_result.png")
    write_nails_to_file(nail_sequence, image_path + "_sequence.ssc", len(image))
    print("Done.")


if __name__ == '__main__':
    main_anim()
