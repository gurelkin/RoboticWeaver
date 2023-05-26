import cv2

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
