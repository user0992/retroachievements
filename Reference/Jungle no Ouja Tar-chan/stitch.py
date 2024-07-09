from PIL import Image
import os
import glob

for folder in glob.glob("maps/*"):
	if not os.path.isdir(folder): continue
	outfn = folder + ".png"

	images = []
	w, h = 0, 0
	for fn in glob.glob(folder + "/*.png"):
		print("getting " + fn)
		x, y = [int(a) for a in os.path.basename(fn).split(".")[0].split("-")]
		img = Image.open(fn)
		images.append((y, x, img))
		w = max(w, x + img.width)
		h = max(h, y + img.height)

	print("sorting...")
	images.sort()

	print("building " + outfn)
	result = Image.new('RGB', (w, h))
	for y, x, img in images:
		result.paste(im=img, box=(x, y))
	result.save(outfn)