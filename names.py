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

# Globals
TARGET_BRIGHTNESS = int(0.95 * WHITE)
OPT_RES = 400  # TODO: find the real optimum using trial and error (so far it seems sufficient)
FONT_SIZE = 6
