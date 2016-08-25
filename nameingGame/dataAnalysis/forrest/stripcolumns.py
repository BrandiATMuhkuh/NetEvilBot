#!/usr/bin/python

import sys
import simplestats
from optparse import OptionParser


	
####################################################
## Main program starts here...
####################################################
def addQuotesIfNeeded(s):
	if s[0] != '"':
		s = '"' + s
	if s[-1] != '"':
		s = s + '"'
	return s

def convertBooleansToInts(obj):
	if str(obj).strip('"').lower() in ['true','false']:
		return '"1"' if str(obj).strip('"').lower() == 'true' else '"0"'
	else:
		return obj

if __name__ == '__main__':
	parser = OptionParser()
	parser.set_usage(parser.get_prog_name() + " column1name newcolumn1name column2name newcolumn2name ...")
	parser.add_option("--boolints", action="store_true", dest="boolints", default=False, help="convert 'true' and 'false' strings to 0/1 ints")
	parser.add_option("--ling", action="store_true", dest="ling", default=False, help="use default columns for linguistics project ")

	parser.set_description("""Strips a BehaviorSpace CSV file to contain only the specified columns.  Good for conserving on memory with large files, etc.
""")

	options , args = parser.parse_args()
	if options.ling:
		args.extend(["categoricalness-angle","phi",
					"desired-instigator-degree", "degree",
					"[step]", "convergence_time",
					"cascaded?", "cascaded?",
					"converged?","converged?",
					"mean [grammar] of nodes", "mean_grammar"])
		options.boolints = True
		
	if (len(args) == 0 or len(args) % 2 != 0):
		parser.print_help()
		sys.exit(1)

	
	chosenColumnIndices = []
	chosenColumnTitles = [addQuotesIfNeeded(s) for s in args[::2]]
	newChosenColumnTitles = [addQuotesIfNeeded(s) for s in args[1::2]]
	inputfile = sys.stdin

	columnTitles = []

	for line in inputfile:
		items = line.split(",")
		# get rid of \n that is in the last item.
		items[-1] = items[-1].strip('\n')
		if (items[0] == '"[run number]"'):
			columnTitles = items
			for title in chosenColumnTitles:
				if (not title in items):
					sys.stderr.write("The column '%s' was not found in this data file!  Condensing was aborted.\n\n"%(title))
					sys.exit(0)
				chosenColumnIndices.append(items.index(title))
			sys.stdout.write(",".join(newChosenColumnTitles) + "\n")
		elif (len(items) > 2 and len(columnTitles) > 0):
			newRowData = [items[i] for i in chosenColumnIndices]
			if options.boolints:
				newRowData = [ convertBooleansToInts(x) for x in newRowData]
			sys.stdout.write(",".join(newRowData) + "\n")
		#else:  #could spit out header lines, but we won't...
			#sys.stdout.write(line)
	
	sys.stdout.flush()
