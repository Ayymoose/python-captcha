import numpy as np
import cv2
import time
import os 
from operator import itemgetter
from shutil import move

# Usage:
# pycaptcha input_image method acceptance_threshold intensity_threshold 
# output: 3 letter string 

#methods = ['cv2.TM_CCOEFF_NORMED','cv2.TM_CCORR_NORMED', 'cv2.TM_SQDIFF_NORMED']

start_time = time.time()

#binarization
INTENSITY_THRESHOLD = 155
#captcha length 
CAPTCHA_LENGTH = 3

WHITE = 0
BLACK = 255

templates = []

for letter in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
	templates.append(letter + '.png')

# Binarises an image based on intensity threshold
def binarise(image, threshold):
	height, width = image.shape[:2]
	bin_img = image.copy()
	for x in range(height):
		for y in range(width):
			if image[x][y] <= threshold:
				bin_img[x][y] = WHITE
			else:
				bin_img[x][y] = BLACK
	return bin_img;
	
# Print the matches for each character 
def print_matches(matches):
	for match in matches:
		print match[0], match[1], match[2]	
	
# Solves the CAPTCHA and returns a 3 character string
def solve_captcha(image):

	#identified characters 
	matches = []
	
	height, width = image.shape[:2]
    # Crop the captcha to increase performance
	#image = image[0:height,30:width-60]		
	image = binarise(image,INTENSITY_THRESHOLD)

	for character, template in enumerate(templates):
	
		# Read each template from the character set 
		template = cv2.imread(template)

		# Convert to grayscale
		template_gray = cv2.cvtColor(template, cv2.COLOR_BGR2GRAY)

		# Find template
		result = cv2.matchTemplate(image,template_gray, cv2.TM_CCOEFF_NORMED)
		min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)
		
		# matches[CHARACTER, X-POSITION, MATCH]
		matches.append([chr(65+character),max_loc[0], max_val])
		
		# Sort by match 
		matches = sorted(matches, key=itemgetter(2))
				
	# Select top CAPTCHA_LENGTH candidates
	matches = sorted(matches, key=itemgetter(2), reverse=True)
	matches = matches[:CAPTCHA_LENGTH]
	# Sort character matches by x-position for correct string 
	matches = sorted(matches, key=itemgetter(1))
	
	captcha = ""
	for pair in matches:
		captcha += pair[0]
	
	return captcha, matches;

folder = "captchas"
files = os.listdir("captchas")
total_captchas = len(files)

matches = []


for file in files:
    image = cv2.imread(os.path.join(folder,file),0)
    result, matches = solve_captcha(image)
    print result

print "Total CAPTCHAs: " + str(total_captchas)
print("Time: %s seconds" % (time.time() - start_time))
