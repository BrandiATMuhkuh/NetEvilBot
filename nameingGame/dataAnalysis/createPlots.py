#!/usr/bin/python
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import sqlite3





##Load data from database
conn = sqlite3.connect('output/combined.sqlite')
c = conn.cursor()


def hist_old2d():
	xedges = []
	yedges = []

	#selections = selRobots = c.execute('select "categoricalness-angle" as angle, "mean [grammar] of nodes" as mean from robot_combined where "bias-target" like "%influentials%" and "robot-learning-rate" = "0.01"')
	#selections = selRobotsBetween = c.execute('select "categoricalness-angle" as angle, "mean [grammar] of nodes" as mean from robot_combined where "bias-target" like "%influentials%" and "robot-learning-rate" = "0.01" and "robot-start-target" like "%page-rank%"')
	selections = selAll = c.execute('select "categoricalness-angle" as angle, "mean [grammar] of nodes" as mean from robot_combined')
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

	query = """select "mean [grammar] of nodes" as mean_grammar  from robot_combined where 
	"categoricalness-angle" == 60 
	and "robot-learning-rate" <= 0.05
	and "bias-target" like "%none%"
	"""
	histList = []

	for row in c.execute(query):
		histList.append(float(row[0]))


	hist, bin_edges = np.histogram(histList, bins='sqrt')
	plt.hist(histList, bins='sqrt')
	plt.show()


def hist2d(learning):
	print "hist 2d"
	query = """select 
	"mean [grammar] of nodes" as mean_grammar,
	"categoricalness-angle" 
	from robot_combined where 
	"robot-learning-rate" <= """ +str(learning)+ """ 
	and "robot-start-target" like "%page-rank%"
	and "bias-target" like "%none%"
	"""
	x_histList = []
	y_histList = []

	for row in c.execute(query):
		x_histList.append(float(row[0]))
		y_histList.append(int(row[1]))

	plt.hist2d(x_histList, y_histList, bins=[100,45])
	plt.title("Histogram with robot learning rate <= "+str(learning))
	plt.savefig('figs/hist_Lower_learn'+str(learning)+'.png')
	#plt.show()

def testme():
	print "testme"
	r = np.random.randn(100,3)
	H, edges = np.histogramdd(r, bins = (5, 8, 4))
	print r


#testme()
#hist1d()
#hist2d(0.01)
#hist2d(0.05)
hist2d(0.1)