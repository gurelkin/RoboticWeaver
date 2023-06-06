import os
import imageio
import pygame
from names import *

pygame.init()
# clock = pygame.time.Clock()
# folder_path = "./videos/"


class Animator:
    def __init__(self, weaving, shape, nails, intensity=INTENSITY, fps=ANIMATION_FPS):
        """
        a class used to animate weaving using pygame
        :param weaving: a list of weavings (pairs of nails locations)
        :param shape: the size of the canvas
        :param nails: a set of nails locations
        :param intensity: line color intensity
        """
        self.weaving = weaving
        self.nails = nails
        self.shape = (shape[1], shape[0])
        self.line_color = (0, 0, 0, 255 * intensity)
        self.screen = pygame.display.set_mode((480, 400))
        self.fps = fps
        print(f"screen is at {self.screen.get_size()}")

    def animate(self, make_video=False, video_name="NO_NAME"):
        self.screen.fill(RGB_WHITE)
        running = True
        index = 0

        while running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False

            if index <= len(self.weaving) - 2:
                surf = pygame.Surface(self.screen.get_size(), pygame.SRCALPHA)
                start_pos = (self.weaving[index][1], self.weaving[index][0])
                end_pos = (self.weaving[index + 1][1], self.weaving[index + 1][0])
                pygame.draw.line(surf, self.line_color, start_pos, end_pos)
                self.screen.blit(surf, (0, 0))
                pygame.display.flip()
                if make_video:
                    filename = os.path.join(VIDEOS_FOLDER, f"{video_name}_frame_{index}.png")
                    pygame.image.save(self.screen, filename)
                index += 1
                # clock.tick(self.fps)
            else:
                running = False

        pygame.quit()

        if make_video:
            n_frames = index
            image_files = [os.path.join(VIDEOS_FOLDER, f"{video_name}_frame_{frame_number}.png") for frame_number in range(n_frames)]

            # create MP4 video
            video_name = os.path.join(VIDEOS_FOLDER, video_name + '.mp4')
            with imageio.get_writer(video_name, mode='I', fps=VIDEO_FPS) as writer:
                for image_file in image_files:
                    image = imageio.v2.imread(image_file)
                    writer.append_data(image)

                for _ in range(EXTRA_FRAMES):  # add a delay with the final result
                    writer.append_data(imageio.v2.imread(image_files[-1]))

            # Delete the temporary image files
            for image_file in image_files:
                os.remove(image_file)
