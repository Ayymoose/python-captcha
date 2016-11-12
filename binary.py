import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('041712813x65mqt.jpg',0)
bin_img = img.copy()

height, width = img.shape[:2]
#print "width: %d" % width 
#print "height: %d" % height 
#print img[2][2]

# binarize

threshold = 155

for x in range(height):
	for y in range(width):
		if img[x][y] <= threshold:
			bin_img[x][y] = 0
		else:
			bin_img[x][y] = 255

cv2.imshow('image',img)
cv2.imshow('binary',bin_img)

#cv2.imwrite('binary_out.png',bin_img)

cv2.waitKey(0)
