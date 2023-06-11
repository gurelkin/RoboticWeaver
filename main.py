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


def write_nails_to_file(nails, path, image_height):
    with open(path, "w") as f:
        for y, x in nails:
            y = image_height - y
            f.write(f"{x} {y}\n")


def main():
    image_path = sys.argv[1]
    board_path = sys.argv[2]
    name = sys.argv[3]
    make_video = len(sys.argv) > 3 and sys.argv[4] == '-v'
    image = read_image(image_path)
    board = read_image(board_path)
    loom = Loom(image, board)
    nails_sequence = loom.weave()
    # write_nails_to_file(nail_sequence, image_path + "_sequence.ssc", len(image))
    save_image(loom.canvas, RESULTS_FOLDER + "/" + name + "_weave.png")
    if make_video:
        anim = Animator(nails_sequence, loom.canvas.shape, loom.nails)
        anim.animate(make_video=True, video_name=name)
    write_nails_to_file(nails_sequence, RESULTS_FOLDER + "/" + name + "_sequence.ssc", len(image_path))


if __name__ == '__main__':
    main()
