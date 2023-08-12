import sys

from utils import *
from animation import Animator
from loom import Loom


# def write_nails_to_file(nails, path, image_height):
#     with open(path, "w") as f:
#         for y, x in nails:
#             y = image_height - y
#             f.write(f"{x} {y}\n")

def write_coordinates_to_file(coordinates, path):
    with open(path, "w") as f:
        for x, y in coordinates:
            f.write(f"{x} {y}\n")


def main():
    image_path = sys.argv[1]
    board_path = sys.argv[2]
    name = sys.argv[3]
    make_video = False #len(sys.argv) > 3 and sys.argv[4] == '-v'
    loom = Loom(image_path, board_path)
    nails_sequence = loom.weave()
    coordinates = [loom.nail2xy[n] for n in nails_sequence]
    # write_nails_to_file(nail_sequence, image_path + "_sequence.ssc", len(image))
    save_image(loom.canvas, RESULTS_FOLDER + "/" + name + "_weave.png")
    if make_video:
        anim = Animator(nails_sequence, loom.canvas.shape, loom.nails)
        anim.animate(make_video=True, video_name=name)
    # write_nails_to_file(nails_sequence, RESULTS_FOLDER + "/" + name + "_sequence.ssc", len(image_path))
    write_coordinates_to_file(coordinates, RESULTS_FOLDER + "/" + name + "_sequence.xy")


if __name__ == '__main__':
    main()
