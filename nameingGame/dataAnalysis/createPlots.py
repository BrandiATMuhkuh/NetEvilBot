#!/usr/bin/python
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import sqlite3

xedges = []
yedges = []



##Load data from database
conn = sqlite3.connect('output/combined.sqlite')
c = conn.cursor()

#selections = selRobots c.execute('select "categoricalness-angle" as angle, "mean[grammar]ofnodes" as mean from robot_combined where "bias-target" like "%influentials%" and "robot-learning-rate" = "0.01"')
#selections = selRobotsBetween = c.execute('select "categoricalness-angle" as angle, "mean[grammar]ofnodes" as mean from robot_combined where "bias-target" like "%influentials%" and "robot-learning-rate" = "0.01" and "robot-start-target" like "%betweenness-centrality%"')
#selections = selAll = c.execute('select "categoricalness-angle" as angle, "mean[grammar]ofnodes" as mean from robot_combined')
selections = selHumansNear = c.execute('select "categoricalness-angle" as angle, "mean[grammar]ofnodes" as mean from human_combined where "bias-target" like "%near%"');

for row in selections:
	#print row[1], np.float64(row[1])
	yedges.append(float(row[0]))
	xedges.append(float(row[1]))




# x = np.random.normal(3, 1, 100)
# y = np.random.normal(1, 1, 100)
# H, xedges, yedges = np.histogram2d(yedges, xedges, bins=[len(yedges), len(xedges)])
# #H = np.ones((4, 4)).cumsum().reshape(4, 4)
# #print H
# plt.imshow(H, interpolation='nearest', origin='low', extent=[xedges[0], xedges[-1], yedges[0], yedges[-1]])


# H = np.ones((4, 4)).cumsum().reshape(4, 4)
# #print(H[::-1]) 


# fig = plt.figure(figsize=(7, 3))
# ax = fig.add_subplot(131)
# ax.set_title('imshow: equidistant')
# im = plt.imshow(H, interpolation='nearest', origin='low',
#                 extent=[xedges[0], xedges[-1], yedges[0], yedges[-1]])
 
# xcenters = xedges[:-1] + 0.5 * (xedges[1:] - xedges[:-1])
# ycenters = yedges[:-1] + 0.5 * (yedges[1:] - yedges[:-1])
# im.set_data(xcenters, ycenters, H)
# ax.images.append(im)
# ax.set_xlim(xedges[0], xedges[-1])
# ax.set_ylim(yedges[0], yedges[-1])
# ax.set_aspect('equal')

#plt.show()



x = xedges
y = yedges

gridx = np.linspace(min(x),max(x),11)
gridy = np.linspace(min(y),max(y),11)

H, xedges, yedges = np.histogram2d(x, y, bins=[gridx, gridy])

# plt.figure()
# plt.plot(x, y, 'ro')
# plt.grid(True)

# plt.figure()
# myextent  =[xedges[0],xedges[-1],yedges[0],yedges[-1]]
# plt.imshow(H.T,origin='low',extent=myextent,interpolation='nearest',aspect='auto')
# plt.plot(x,y,'ro')
# plt.colorbar()


plt.hexbin(x, y)
plt.show()

#plt.hexbin(xedges, yedges)
#plt.show()







