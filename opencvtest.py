import numpy as np
import cv2
import time
start_time = time.time()



#methods = ['cv2.TM_CCOEFF_NORMED','cv2.TM_CCORR_NORMED', 'cv2.TM_SQDIFF_NORMED']

templates = []
image = cv2.imread('110617642vkvfwq.jpg',0)

#binarization

bin_img = image.copy()
height, width = image.shape[:2]
intensity_threshold = 155

for x in range(height):
	for y in range(width):
		if image[x][y] <= intensity_threshold:
			bin_img[x][y] = 0
		else:
			bin_img[x][y] = 255
			
image = bin_img

for letter in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
	templates.append(letter + '.png')

#reject matches below 88%
threshold = 0.88

#identified characters 
positions = []

for character, template in enumerate(templates):
	
	# 'I' is a special case
	if character != 8:
		template = cv2.imread(template)

		# Convert to grayscale
		#imageGray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
		templateGray = cv2.cvtColor(template, cv2.COLOR_BGR2GRAY)

		# Find template
		result = cv2.matchTemplate(image,templateGray, cv2.TM_CCOEFF_NORMED)
		min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)
		
		top_left = max_loc
		#h,w = templateGray.shape
		#bottom_right = (top_left[0] + w, top_left[1] + h)
		#cv2.rectangle(image,top_left, bottom_right,(0,0,255),1)
		if (max_val > threshold):
			positions.append([top_left[0], chr(65+character)])
			print chr(65+character), max_val
# sort by x-position 
positions.sort()
string = ""
for pair in positions:
	string += pair[1]

print string
print("Time: %s seconds" % (time.time() - start_time))
	

 
# Show result
cv2.imshow("Image", image)
cv2.moveWindow("Template", 10, 50);


cv2.waitKey(0)