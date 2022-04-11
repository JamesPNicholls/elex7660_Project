    # the contours detected in an image.
import numpy as np
import cv2

# Scale image to make this easier for myself
img = cv2.imread('clock.png', cv2.IMREAD_UNCHANGED)
 
print('Original Dimensions : ',img.shape)
 
scale_percent = 1200 # percent of original size
width = int(img.shape[1] * scale_percent / 100)
height = int(img.shape[0] * scale_percent / 100)
dim = (width, height)
  

# resize image
resized = cv2.resize(img, dim, interpolation = cv2.INTER_AREA)

print('Resized Dimensions : ',resized.shape)
 
cv2.imwrite("resized.png", resized)

# Reading image
font = cv2.FONT_HERSHEY_COMPLEX
img2 = cv2.imread('resized.png', cv2.IMREAD_ANYCOLOR | cv2.IMREAD_ANYDEPTH)
cv2.imshow
# Reading same image in another 
# variable and converting to gray scale.
img = cv2.imread('resized.png', cv2.IMREAD_GRAYSCALE | cv2.IMREAD_ANYDEPTH)
  
# Converting image to a binary image
# ( black and white only image).
_, threshold = cv2.threshold(img, 110, 255, cv2.THRESH_BINARY)
  
# Detecting contours in image.
contours, _= cv2.findContours(threshold, cv2.RETR_TREE,
                               cv2.CHAIN_APPROX_SIMPLE)
  
lst = []
# Going through every contours found in the image.
for cnt in contours :
  
    approx = cv2.approxPolyDP(cnt, 0.009 * cv2.arcLength(cnt, True), True)
  
    # draws boundary of contours.
    cv2.drawContours(img2, [approx], 0, (0, 0, 255), 5) 
  
    # Used to flatted the array containing
    # the co-ordinates of the vertices.
    n = approx.ravel() 
    i = 0

    for j in n :
        if(i % 2 == 0):
            x = n[i]
            y = n[i + 1]
            lst.append([round(x*100/scale_percent), round(y*100/scale_percent)]) 
            # String containing the co-ordinates.
            string = str(round(x*100/scale_percent)) + " " + str(round(y*100/scale_percent)) 
            
            if(i == 0):
                cv2.putText(img2, string, (x, y),
                                font, 0.5, (255, 0, 0)) 
            else:
                # text on remaining co-ordinates.
                cv2.putText(img2, string, (x, y), 
                          font, 0.5, (0, 255, 0)) 
        i = i + 1
cv2.imshow('img2', img2) 
  
# Exiting the window if 'q' is pressed on the keyboard.
if cv2.waitKey(0) & 0xFF == ord('q'): 
    cv2.destroyAllWindows()

    