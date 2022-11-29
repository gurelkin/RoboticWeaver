import numpy as np
import matplotlib.pyplot as plt
import cv2
from skimage.draw import line_aa

import preprocessing as pre

if __name__ == '__main__':
    # plt.imshow(pre.read_image("MonaLisa.jpg"), cmap='gray')
    # plt.show()

    shape = (1000, 1000)
    k = 52
    locs = pre.nails_locations_new(shape, k)
    canvas = np.zeros(shape)

    for nail1 in locs:
        for nail2 in locs:
            rr, cc, val = line_aa(*nail1, *nail2)
            val *= 0.5
            canvas[rr, cc] += val
    for index in np.ndindex(canvas.shape):
        canvas[index] = min(canvas[index], 1)
        canvas[index] = 1-canvas[index]

    plt.imshow(canvas, cmap='gray')
    plt.show()

