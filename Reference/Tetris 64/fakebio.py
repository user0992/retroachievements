import time
import random

bpm = 90
while True:
	bpm += int(random.gauss(0, 3))
	with open("output.txt", "w") as f:
		f.write(str(bpm))
	print("new bpm", bpm)
	time.sleep(0.5)