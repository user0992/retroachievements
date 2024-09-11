# for PS2 texture dumps

import os
import glob

from PIL import Image

os.makedirs("fixed")
for filename in glob.glob("./*.png"):
	print("FIXING:", filename)
	img = Image.open(filename)
	px = img.load()

	w, h = img.size
	for i in range(0, w):
		for j in range(0, h):
			r, g, b, a = px[i, j]
			px[i, j] = (r, g, b, (a + 128) & 0xFF)

	img.save(os.path.join("fixed", os.path.basename(filename)))
	img.close()