import cv2
import numpy as np
import skimage
from matplotlib import pyplot as plt
from skimage.feature import blob_log

from loom import threshold_contrast
from main import read_image, plot_image
from names import Image, Nail


def capture_video():
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
        frame = cv2.convertScaleAbs(frame, alpha=1.5, beta=10)
        key = cv2.waitKey(20)
        if key == 27:  # exit on ESC
            cv2.imwrite("captured.png", captured)
            break
        elif key == 32:  # space
            captured = frame

    vc.release()
    cv2.destroyWindow("preview")



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


def find_nails_locations(board: Image, epsilon=7) -> list[Nail]:
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


def main_cap():
    board = read_image("frames/nails_polygon.jpg")
    negative = 255 - board
    thresh = 1.5 * np.math.floor(np.mean(negative))
    negative = threshold_contrast(negative, thresh)
    negative = skimage.filters.gaussian(negative,
                                        sigma=0.25,
                                        preserve_range=True)
    plot_image(negative)
    plt.imshow(board)
    bl = blob_log(negative)
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


if __name__ == "__main__":
    board = read_image("Images/captured.png")
    new_nails = find_nails_locations(board, epsilon=14)
    plt.imshow(board)
    plt.scatter([n[1] for n in new_nails],
                [n[0] for n in new_nails])
    plt.show()

