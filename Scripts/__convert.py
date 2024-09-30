# dumps stub achievement structures for the contents of a RA Set Planning sheet
# export spreadsheet as csv, and load it with this script

import sys
import csv

with open(sys.argv[1], "r") as f:
	csvreader = csv.reader(f)
	for _ in range(3): next(csvreader)
	for line in csvreader:
		if line[4].strip() == "": continue
		print("""
achievement(
    title="{2}",
    description="{4}",
    points={5},
    trigger=always_false()
)""".format(*line))