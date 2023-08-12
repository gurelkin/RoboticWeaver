import cv2
import skimage
from skimage import io, color
from skimage.feature import blob_log

from utils import *
from loom import threshold_contrast


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
            cv2.imwrite(FRAMES_FOLDER + "captured.png", captured)
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

def main_mask():
    image_path = "captured.png"
    image = io.imread(image_path)

    hsv_image = color.rgb2hsv(image)

    lower_green = np.array([0.25, 0.2, 0.2])  # Adjust these values as needed
    upper_green = np.array([0.4, 1.0, 1.0])

    # preparing the mask to overlay
    mask = np.logical_and(hsv_image >= lower_green, hsv_image <= upper_green)
    green_elements = np.logical_and.reduce(mask, axis=2)
    highlighted_image = image.copy()
    highlighted_image[green_elements] = [255, 0, 0]  # Red color

    # Display or save the highlighted image
    plt.imshow(highlighted_image)
    plt.axis('off')
    plt.show()

if __name__ == "__main__":
    main_mask()
