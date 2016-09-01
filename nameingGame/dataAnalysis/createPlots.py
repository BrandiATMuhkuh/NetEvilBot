#!/usr/bin/python
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import sqlite3
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.cm as cm



##Load data from database
conn = sqlite3.connect('output/combined.sqlite')
c = conn.cursor()


def hist_old2d():
	xedges = []
	yedges = []

	selections = selRobots = c.execute('select "categoricalness-angle" as angle, "mean [grammar] of nodes" as mean from robot_combined where "bias-target" like "%influentials%" and "robot-learning-rate" = "0.01" and "robot-start-target" like "%page-rank%"')
	#selections = selRobotsBetween = c.execute('select "categoricalness-angle" as angle, "mean [grammar] of nodes" as mean from robot_combined where "bias-target" like "%influentials%" and "robot-learning-rate" = "0.01" and "robot-start-target" like "%page-rank%"')
	#selections = selAll = c.execute('select "categoricalness-angle" as angle, "mean [grammar] of nodes" as mean from robot_combined')
	#selections = selHumansNear = c.execute('select "categoricalness-angle" as angle, "mean [grammar] of nodes" as mean from human_combined where "bias-target" like "%near%"');

	for row in selections:
		#print row[1], np.float64(row[1])
		yedges.append(float(row[0]))
		xedges.append(float(row[1]))




	x = xedges
	y = yedges

	gridx = np.linspace(min(x),max(x),11)
	gridy = np.linspace(min(y),max(y),11)

	H, xedges, yedges = np.histogram2d(x, y, bins=[gridx, gridy])


	plt.hexbin(x, y)
	plt.show()

	#plt.hexbin(xedges, yedges)
	#plt.show()


def hist1d():
	print "hist 1d"

	query = """select 
	"mean [grammar] of nodes" as mean_grammar,
	"categoricalness-angle" 
	from robot_combined where 
	"robot-learning-rate" = 0.05 
	and "robot-start-target" = '"betweenness-centrality"'
	and "bias-target" = '"influentials"' 
	and "num-of-robots" <= 2
	and "robot-learning-rate" > 0 
	and "degree-of-instigator" = 17
	"""
	histList = []

	for row in c.execute(query):
		#print row
		histList.append(float(row[0]))

	#print histList
	hist, bin_edges = np.histogram(histList, bins=100)
	plt.hist(histList, bins='sqrt')
	plt.show()


def hist2d(robot = True, learning=0.05, learningExact=False, startTarget = "page-rank", biasTarget = "none", robotNumbers = 33, robotExact = True):
	print "hist2d ",robotExact

	person = "Robot"
	if robot == False:
		person = "Human"

	if learningExact == True:
		learningExact = "="
	else:
		learningExact = "<="

	if robotExact == True:
		robotExact = "="
	else:
		robotExact = "<="
	
	query = """select 
	"mean [grammar] of nodes" as mean_grammar,
	"categoricalness-angle" 
	from robot_combined where 
	"robot-learning-rate" """ +learningExact+ """ """ +str(learning)+ """ 
	and "robot-start-target" = '\"""" +startTarget+ """\"'
	and "bias-target" = '\"""" +biasTarget+ """\"' 
	and "num-of-robots" """ +robotExact+ """ """ + str(robotNumbers) + """
	and "robot-learning-rate" > 0
	"""


	#query = 'select "mean [grammar] of nodes" as mean_grammar, "categoricalness-angle" from robot_combined where "bias-target" like "%influentials%" and "robot-learning-rate" = "0.01"  and "robot-start-target" like "%page-rank%"'

	print query
	filename = str(person)+" - learning: "+str(learning)+" - target: "+startTarget+" - bias: "+biasTarget+" - robots: "+str(robotNumbers)+ " - learningExact: " +learningExact+ "- robotExact: " + robotExact +".png"

	print filename
	
	#return
	x_histList = []
	y_histList = []

	for row in c.execute(query):
		x_histList.append(float(row[0]))
		y_histList.append(float(row[1]))

	bins=[100,45]

	gridx = np.linspace(min(x_histList),max(x_histList),100)
	gridy = np.linspace(min(y_histList),max(y_histList),47)
	#bins=[gridx, gridy]
	#print bins
	#H, xedges, yedges = np.histogram2d(x, y, bins=[gridx, gridy])


	#plt.hist2d(x_histList, y_histList, bins=bins, range=[[0.000000, 1.0000000], [0.01, 0.1]], cmin=10)
	plt.xlabel('Mean Network Grammar (0-1)')
	plt.ylabel('Robot Learning Rate (0.01-0.1')
	plt.title("Histogram with robot learning rate <= "+str(learning))


	plt.hist2d(x_histList, y_histList, bins=bins, range=[[0.000000, 1.0000000], [45, 90]], cmin=10)
	#plt.title("Histogram with robot learning rate <= "+str(learning))
	plt.savefig('figs/'+filename)
	#plt.show()



def hist2d_learn(robot = True, learning=0.05, learningExact=False, startTarget = "page-rank", biasTarget = "none", robotNumbers = 33, robotExact = False):
	print "hist2d"

	person = "Robot"
	if robot == False:
		person = "Human"

	if learningExact == True:
		learningExact = "="
	else:
		learningExact = "<="

	if robotExact == True:
		robotExact = "="
	else:
		robotExact = "<="
	
	query = """select 
	"mean [grammar] of nodes" as mean_grammar,
	"robot-learning-rate"
	from robot_combined where 
	"categoricalness-angle" = 80  
	and "robot-start-target" = '\"""" +startTarget+ """\"'
	and "bias-target" = '\"""" +biasTarget+ """\"' 
	and "num-of-robots" """ +robotExact+ """ """ + str(robotNumbers) + """
	and "robot-learning-rate" > 0
	"""



	#query = 'select "mean [grammar] of nodes" as mean_grammar, "categoricalness-angle" from robot_combined where "bias-target" like "%influentials%" and "robot-learning-rate" = "0.01"  and "robot-start-target" like "%page-rank%"'

	print query
	filename = str(person)+" - target: "+startTarget+" - bias: "+biasTarget+" - robots: "+str(robotNumbers)+ " - learningExact: " +learningExact+ "- robotExact: " + robotExact +".png"

	print filename
	
	#return
	x_histList = []
	y_histList = []

	for row in c.execute(query):
		x_histList.append(float(row[0]))
		y_histList.append(float(row[1]))
	bins=[100,10]

	gridx = np.linspace(min(x_histList),max(x_histList),100)
	gridy = np.linspace(min(y_histList),max(y_histList),12)
	#bins=[gridx, gridy]
	#print bins
	#H, xedges, yedges = np.histogram2d(x, y, bins=[gridx, gridy])
	plt.clf()
	plt.hist2d(x_histList, y_histList, bins=bins, range=[[0.000000, 1.0000000], [0.01, 0.1]], cmin=10)
	
	plt.xlabel('Mean Network Grammar (0-1)')
	plt.ylabel('Robot Learning Rate (0.01-0.1')
	plt.title("Histogram with robot learning rate <= "+str(learning))
	#plt.colorbar()
	plt.savefig('figs/learn/'+filename)
	#plt.show()





def testme():
	print "testme"
	r = np.random.randn(100,3)
	H, edges = np.histogramdd(r, bins = (5, 8, 4))
	print r


def runAllRobotStats():
	print "run all stats"
	biasTargets = ["none", "nearby", "influentials"]
	startTargets = ["random", "betweenness-centrality", "closeness-centrality", "page-rank"]
	learnings = [0.01, 0.05, 0.1]
	learningExacts = [False, True]
	robotExact = [False, True]
	robotNumbers = [2,15,29]

	imageCount = 0;
	for robots in robotNumbers:
		for rExact in robotExact:
			for start in startTargets:
				for learning in learnings:
					for lExact in learningExacts:
						for bias in biasTargets:
							hist2d(robot = True, learning=learning, learningExact=lExact, startTarget = start, biasTarget = bias, robotNumbers = robots, robotExact = rExact)


def runAllLearnStats():
	robotNumbers = [2,15,29]
	startTargets = ["random", "betweenness-centrality", "closeness-centrality", "page-rank"]
	for robots in robotNumbers:
		for start in startTargets:
			hist2d_learn(robot = True, learning=0.1, learningExact=False, startTarget = start, biasTarget = "none", robotNumbers = robots, robotExact = False)


#runAllLearnStats()
runAllRobotStats()
#hist2d_hexbin(robot = True, learning=0.1, learningExact=True, startTarget = "page-rank", biasTarget = "nearby", robotNumbers = 33, robotExact = False)

#testme()
#hist1d()
#hist2d(0.01)
#hist2d(0.05)
#hist2d(0.1)


#('select "categoricalness-angle" as angle, "mean [grammar] of nodes" as mean from robot_combined where "bias-target" like "%influentials%" and "robot-learning-rate" = "0.01" and "robot-start-target" like "%page-rank%"')
#hist2d(robot = True, learning=0.1, learningExact=True, startTarget = "page-rank", biasTarget = "influentials", robotNumbers = 33, robotExact = False)

#hist_old2d()