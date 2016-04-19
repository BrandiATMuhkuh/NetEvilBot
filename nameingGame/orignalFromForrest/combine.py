#!/usr/bin/python

import sys, os, fnmatch
from optparse import OptionParser


def uniq(alist):   # remove duplicates, preserve order
	set = {}
	return [set.setdefault(e,e) for e in alist if e not in set]
	
	
def stripQuotes(s):
	return s.strip('" \n\t')

####################################################
## Main program starts here...
####################################################

if __name__ == '__main__':
	parser = OptionParser()
	parser.set_usage(parser.get_prog_name() + " bsdata1.csv bsdata2.csv [...] ")
	parser.set_description("""Combines two or more NetLogo BehaviorSpace .csv files, and spits to stdout.

Note that you can specify wildcards, such as "bsdata*.csv" 
""")
	parser.add_option("-f", "--final", action="store_true", dest="finalTicksOnly", help="Only pull the final tick row of each experiment.")
	
	options , filepatterns = parser.parse_args()
	if (len(filepatterns) == 0):
		parser.print_help()
		sys.exit(0)
		
	currentDirFiles = sorted(os.listdir("."))
	filenames = []
	for fPat in filepatterns:
		filenames.extend(fnmatch.filter(currentDirFiles, fPat))
	
	filenames = uniq(filenames)
	
	if (len(filenames) < 1):
		parser.print_help()
		sys.exit(1)
	
	dataKeys = []
	dataElems = {}
	headingsLine = None
	renumberIndex = 0
		
	for filename in filenames:
		inputfile = file(filename, "r")

		columnTitles = []
		lastRunNumber = None
		lastRowLine = ""
		lastRowKey = None
	
		for line in inputfile:
			items = line.split(",")
			if (items[0] == '"[run number]"'):
				columnTitles = items
				tickColumnIndex = columnTitles.index('"[step]"')
				if (headingsLine == None):
					headingsLine = line
			elif (len(items) > 2 and len(columnTitles) > 0):
				currentKey = tuple(items[1:tickColumnIndex])
				
				if (not currentKey in dataKeys):
					dataKeys.append(currentKey)
					dataElems[currentKey] = []

				if (items[0] != lastRunNumber):
					if (lastRunNumber != None and options.finalTicksOnly):
						dataElems[lastRowKey].append(lastRowLine)
					lastRunNumber = items[0]
					renumberIndex += 1
				
				renumberedLine = ",".join([ '"%s"'%renumberIndex ] + items[1:])
				lastRowLine = renumberedLine
				lastRowKey = currentKey
				if (not options.finalTicksOnly):
					dataElems[currentKey].append(renumberedLine)
		if (lastRowKey != None and options.finalTicksOnly):
			dataElems[lastRowKey].append(lastRowLine)

	sys.stdout.write('"Combined BehaviorSpace file"\n"merged files:",\n')
	sys.stdout.write('"' + '","'.join(sys.argv) + '"')
#	for filename in filenames:
#		sys.stdout.write(',"%s"'%filename)
	sys.stdout.write('\n\n')
	sys.stdout.write('"# of files combined:","%s"\n'%len(filenames))
	sys.stdout.write('\n')

	sys.stderr.write('"Summary of combined file:"\n')
	
	s = str(columnTitles[1:tickColumnIndex]).replace('"','')
	sys.stderr.write('"%s"\n'%s)
	for key in dataKeys:
		s = str(key).replace('"','')
		sys.stderr.write('"%s :: %s rows"\n'%(s,len(dataElems[key])))

	sys.stderr.write('\n\n')
	sys.stdout.write(headingsLine)
	

	for key in dataKeys:
		for row in dataElems[key]:
			sys.stdout.write(row)

	sys.stdout.write('\n')
	sys.stdout.flush()
