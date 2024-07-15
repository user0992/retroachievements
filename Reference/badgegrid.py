from PIL import Image, ImageDraw
import os
import sys
import math
import glob

bgcolor = "#2b374a"
border = 10
rowlen = 10

images = []
for fn in glob.glob("*.png"):
	img = Image.open(fn)
	if img.width != 64 or img.height != 64: continue
	if os.path.basename(img.filename).startswith("_"): continue
	images.append(img)

w = border + (64 + border) * min(rowlen, len(images))
h = border + (64 + border) * math.ceil(len(images) / rowlen)
result = Image.new('RGB', (w, h))
rect = ImageDraw.Draw(result)
rect.rectangle([(0, 0), (w, h)], fill=bgcolor)

for i,img in enumerate(images):
	x = border + (64 + border) * (i % rowlen)
	y = border + (64 + border) * (i // rowlen)
	result.paste(im=img, box=(x, y))
result.save("_ALLBADGES.png")