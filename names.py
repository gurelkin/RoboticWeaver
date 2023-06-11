import numpy as np

# Types
Image = np.array(list[list[int]])
Canvas = np.array(list[list[int]])
Nail = tuple[int, int]
Pixel = tuple[int, int]
Line = list[Pixel]

# Constants
WHITE = 255
GREY = 127
BLACK = 0
RGB_WHITE = (255, 255, 255)  # pygame works with 3 color channels

# Globals
INTENSITY = 0.15
TARGET_BRIGHTNESS = int(0.95 * WHITE)
OPT_RES = 400
FONT_SIZE = 6
ANIMATION_FPS = 1_000
VIDEO_FPS = ANIMATION_FPS / 4
EXTRA_FRAMES = 400

# Folder paths
IMAGES_FOLDER = "./images"
FRAMES_FOLDER = "./frames"
RESULTS_FOLDER = "./results"
VIDEOS_FOLDER = r"C:\Users\urizi\Documents\GitHub\RoboticWeaver\videos"
WEBSITE_FOLDER = "./website"
ROBOT_FOLDER = "./robot"
