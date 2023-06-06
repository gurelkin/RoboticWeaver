import cv2
import numpy as np
import skimage
from matplotlib import pyplot as plt
from skimage.feature import blob_log
from main import read_image, plot_image

cv2.namedWindow("preview")
vc = cv2.VideoCapture(1)

if vc.isOpened():  # try to get the first frame
    rval, frame = vc.read()
else:
    rval = False
captured = frame

while rval:
    cv2.imshow("preview", frame)
    cv2.imshow("cap", captured)
    rval, frame = vc.read()
    key = cv2.waitKey(20)
    if key == 27:  # exit on ESC
        cv2.imwrite("captured.png", captured)
        break
    elif key == 32:  # space
        captured = frame

vc.release()
cv2.destroyWindow("preview")


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


def main_cap():
    mona = read_image("Images/MonaLisa.jpeg")
    board = read_image("Images/captured.png")
    THRESH = 140
    negative = 255 - board
    negative = skimage.filters.gaussian(negative,
                                        sigma=1,
                                        preserve_range=True)
    thresh = 1.6 * np.math.floor(np.mean(negative))
    negative = threshold_contrast(negative, thresh)
    plot_image(negative)
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
