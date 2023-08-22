import numpy as np
import cv2
import matplotlib.pyplot as plt
from skimage.io import imread

# Constants
WHITE = 255
GREY = 127
BLACK = 0
RGB_WHITE = (255, 255, 255)  # pygame works with 3 color channels
RGB_GREEN = (0, 255, 0)
lower_red_1 = np.array([0, 100, 100])
upper_red_1 = np.array([10, 255, 255])
lower_red_2 = np.array([160, 100, 100])
upper_red_2 = np.array([180, 255, 255])
ANCHORS = [[335, 642.5],
           [-186.65, 630.64],
           [339, -5.82],
           [-179.06, -17.17]]

# Global variables
INTENSITY = 0.15
TARGET_BRIGHTNESS = int(0.95 * WHITE)
OPT_RES = 400
FONT_SIZE = 6
ANIMATION_FPS = 1_000
VIDEO_FPS = ANIMATION_FPS / 4
EXTRA_FRAMES = 400
BASE_NAILS_XY = [(-73.56, 162.41), (201.07, 503.41)]

# Folder paths
IMAGES_FOLDER = "./images"
FRAMES_FOLDER = "./frames"
RESULTS_FOLDER = "./results"
VIDEOS_FOLDER = "./videos"
WEBSITE_FOLDER = "./website"
ROBOT_FOLDER = "./robot"


# Image i/o utils
def read_image(path: str, color: bool) -> np.array:
    """
    Reads an image from `path`.

    :param path: Path to the image
    :param color: True for RGB image, False for grayscale
    :return: A grayscale variant of the image as a 2d numpy array
    """
    if color:
        bgr = cv2.imread(path, cv2.IMREAD_COLOR)
        return cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB).astype(np.uint8)
    else:
        return np.array(WHITE * imread(path, as_gray=True, plugin='matplotlib'), dtype=int)


def plot_image(image):
    """
    Plots `image` in color (if True) or grayscale (if False).
    """
    if len(image.shape) > 2:
        plt.imshow(image)
    else:
        plt.imshow(image, cmap='gray', vmin=BLACK, vmax=WHITE)
    plt.show()


def save_image(image, path):
    """
    Saves `image` in the requested `path`.
    """
    plt.imshow(image, cmap='gray', vmin=BLACK, vmax=WHITE)
    plt.savefig(path)
