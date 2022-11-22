import numpy as np
import matplotlib.pyplot as plt
import cv2
import preprocessing as pre


if __name__ == '__main__':
    # plt.imshow(pre.read_image("MonLisa.jpg"), cmap='gray')
    # plt.show()
    shape = (1000, 1000)
    k = 500
    locs = pre.nails_locations(shape, k)
    canvas = np.zeros(shape)
    for n in locs:
        canvas[n] = 1
    plt.imshow(canvas, cmap='gray')
    plt.show()

