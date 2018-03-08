import cv2 as cv
import time
import os 
from operator import itemgetter
from shutil import move

#methods = ['cv2.TM_CCOEFF_NORMED','cv2.TM_CCORR_NORMED', 'cv2.TM_SQDIFF_NORMED']

folder = "captchas"
set_path = "set"

#Constants
INTENSITY_THRESHOLD = 155
CAPTCHA_LENGTH = 3
WHITE = 0
BLACK = 255

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
    matches = []
    height, width = image.shape[:2]
    # Crop the captcha to decreasing processing time
    image = image[0:height,30:width-60]		
    # 1. Binarise the CAPTCHA
    image = binarise(image,INTENSITY_THRESHOLD)

    # 2. Use template matching with each letter of the alphabet on the binarise CAPTCHA
    for character, template in enumerate('ABCDEFGHIJKLMNOPQRSTUVWXYZ'):
	
		# Read each template from the character set 
        template = cv.imread(set_path + '/' + template + '.png')

		# Convert to grayscale
        template_gray = cv.cvtColor(template, cv.COLOR_BGR2GRAY)

		# Find template
        result = cv.matchTemplate(image,template_gray, cv.TM_CCOEFF_NORMED)
        min_val, max_val, min_loc, max_loc = cv.minMaxLoc(result)
		
		# matches[CHARACTER, X-POSITION, MATCH]
        matches.append([chr(ord('A')+character),max_loc[0], max_val])
		
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


# Solves all the captchas in a directory and renames the original file to the solved captcha

files = os.listdir("captchas")
total_captchas = len(files)

matches = []

start_time = time.time()

for file in files:
    image = cv.imread(os.path.join(folder,file),0)
    result, matches = solve_captcha(image)
    move(os.path.join(folder,file), os.path.join(folder,result+'.jpg'))
    #print result

print "Total CAPTCHAs: " + str(total_captchas)
print("Time: %s seconds" % (time.time() - start_time))
