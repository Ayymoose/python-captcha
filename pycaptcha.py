import numpy as np
import cv2
import time
import os 
from operator import itemgetter

# Usage:
# pycaptcha input_image method acceptance_threshold intensity_threshold 
# output: 3 letter string 


#methods = ['cv2.TM_CCOEFF_NORMED','cv2.TM_CCORR_NORMED', 'cv2.TM_SQDIFF_NORMED']



#for file in files:
#	print str(file)

start_time = time.time()


#binarization
INTENSITY_THRESHOLD = 155
#reject matches below 
THRESHOLD = 0.87
#captcha length 
CAPTCHA_LENGTH = 3

templates = []


for letter in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
	templates.append(letter + '.png')

# Binarizes an image based on intensity threshold
def binarize(image, threshold):
	height, width = image.shape[:2]
	bin_img = image.copy()
	for x in range(height):
		for y in range(width):
			if image[x][y] <= threshold:
				bin_img[x][y] = 0
			else:
				bin_img[x][y] = 255
	return bin_img;
	
# Print the matches for each character 
def print_matches(matches):
	for match in matches:
		print match[0], match[1], match[2]	
	
# Solves the CAPTCHA and returns a 3 character string
def solve_captcha(image, threshold):

	#identified characters 
	positions = []
	matches = []
	
	height, width = image.shape[:2]
	image = image[0:height,30:width-60]		
	image = binarize(image,INTENSITY_THRESHOLD)

	for character, template in enumerate(templates):
	
		# Read each template from the character set 
		template = cv2.imread(template)

		# Convert to grayscale
		template_gray = cv2.cvtColor(template, cv2.COLOR_BGR2GRAY)

		# Find template
		result = cv2.matchTemplate(image,template_gray, cv2.TM_CCOEFF_NORMED)
		min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)
		
		#top_left = max_loc
		#h,w = templateGray.shape
		#bottom_right = (top_left[0] + w, top_left[1] + h)
		#cv2.rectangle(image,top_left, bottom_right,(0,0,255),1)
		
		# Reject results beold THRESHOLD %
		if (max_val > threshold):
			positions.append([chr(65+character),max_loc[0], max_val])
			
		matches.append([chr(65+character),max_loc[0], max_val])
		
	# Method 1 for removing false matches on the character 'I' 
	# If the failed CAPTCHA is more than 3 characters long and contains an 'I'  
	# and the match is the lowest of the other characters, reject the 'I'
	if len(positions) > CAPTCHA_LENGTH:
		# Sort by match 
		positions = sorted(positions, key=itemgetter(2))
		# If the lowest match in the captcha is 'I', remove it from the list
		for index,p in enumerate(positions):
			if p[0] == 'I':
				del positions[index]

	# Sort character matches by x-position for correct string  
	positions = sorted(positions, key=itemgetter(1))
	
	captcha = ""
	for pair in positions:
		captcha += pair[0]
	
	return matches, captcha, positions;

	
folder = "captchas"
files = os.listdir("captchas")

total_captchas = len(files)
failed = 0

positions = []

for file in files:
	image = cv2.imread(os.path.join(folder,file),0)
	matches, result, positions = solve_captcha(image,THRESHOLD)
	#print os.path.join(folder,file), os.path.join(folder,result+'.jpg')
	#os.rename(os.path.join(folder,file), os.path.join(folder,result+'.jpg'))
	if len(result) != CAPTCHA_LENGTH:
		failed += 1
		print "Failed '" + result + "' in " + str(file) 
		print positions
		print_matches(matches) 
		
accuracy = 100 * ((total_captchas - failed)/float(total_captchas))
print "Total CAPTCHAs: " + str(total_captchas)
print "Failed: " + str(failed)
print "Accuracy: %.2f%% " % accuracy
print("Time: %s seconds" % (time.time() - start_time))
	
# Show result
#cv2.imshow("Image", image)
#cv2.moveWindow("Template", 10, 50);
#cv2.waitKey(0)