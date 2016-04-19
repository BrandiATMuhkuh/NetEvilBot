#!/usr/bin/env python

import pylab
from pylab import *
import matplotlib.lines as mpllines

from matplotlib.font_manager import FontProperties

from matplotlib import rc
rc('font',**{'family':'sans-serif','sans-serif':['Arial']})
#rc('text', usetex=True)

def fixName(s):
	if (s == "influentials"):
		return "hubs"
	else:
		return s

cdict = {
 'blue': ((0.0, 0.0, 0.0),(0.001, 0.0, 0.5),
		  (0.11, 1, 1),
		  (0.34000000000000002, 1, 1),
		  (0.65000000000000002, 0, 0),
		  (1, 0, 0)),
 'green': ((0.0, 0.0, 0.0),(0.001, 0, 0),
		   (0.125, 0, 0),
		   (0.375, 1, 1),
		   (0.64000000000000001, 1, 1),
		   (0.91000000000000003, 0, 0),
		   (1, 0, 0)),
 'red': ((0.0, 0.0, 0.0),(0.001, 0, 0),
		 (0.34999999999999998, 0, 0),
		 (0.66000000000000003, 1, 1),
		 (0.89000000000000001, 1, 1),
		 (1, 0.5, 0.5))}

modifiedJet = matplotlib.colors.LinearSegmentedColormap('modifiedJet', cdict, 256)


def make2DHistogram(dat,datSubset,interpolation='nearest',contourLines=0,cmap=cm.jet,showColorBar=True,label_font_size=7):
	""" from stripped .csv files"""
	X = dat['degree']
	Y = dat['phi']
	xi = float64(array(sorted(set(X))))
	yi = float64(array(sorted(set(Y))))
	xstep = xi[1]-xi[0]
	ystep = yi[1]-yi[0]
	maxFreq = float(len(dat)) / (len(xi) * len(yi))
	xBounds = (xi[0]-xstep/2.0,xi[-1]+xstep/2.0)
	yBounds = (yi[0]-ystep/2.0,yi[-1]+ystep/2.0)
	H,xedges,yedges = histogram2d(datSubset['degree'],datSubset['phi'],bins=(len(xi),len(yi)),range=(xBounds,yBounds))
	extent = list(xBounds) + list(yBounds)
	zi = H.transpose() / maxFreq

	imshow(flipud(zi),aspect='auto',extent=extent,interpolation=interpolation,cmap=cmap)
	if showColorBar:
		#c = colorbar(fraction=0.18,aspect=15,extend="min")
		c = colorbar(aspect=25, pad=0.08, extend="min", ticks=[0,0.2,0.4,0.6,0.8,1.0])
		c.ax.set_position([0.9,0.6,0.14,0.36])
		#reduce colorbar ticks font size
		for ticklabel in c.ax.get_yticklabels():
			ticklabel.set_size(12)
			
	clim(0.0,1.0)
	if (contourLines > 0):
		contour(xi,yi,zi,contourLines,linewidths=1.5,colors='k',extent=extent)
	#xlim(2,55)
	xlabel("innovator degree",fontsize=label_font_size)
#	ylabel(r"$\phi$ {\small (in  $^\circ$)}",fontsize=10)
	ylabel(r"$\phi$",fontsize=label_font_size*10/7)
	yticks([45,60,75,90])
	
	#HACK to make the axes ticks go outward instead of inward
	ax = gca()
	lines = ax.get_xticklines()
	labels = ax.get_xticklabels()
	for line in lines:
		if line.get_marker() == mpllines.TICKUP:
			line.set_marker(mpllines.TICKDOWN)
		else:
			line.set_visible(False)
	for label in labels:
		label.set_y(-0.02)
	lines = ax.get_yticklines()
	labels = ax.get_yticklabels()
	for line in lines:
		if line.get_marker() == mpllines.TICKRIGHT:
			line.set_marker(mpllines.TICKLEFT)
		else:
			line.set_visible(False)
	for label in labels:
		label.set_x(-0.02)
	



#~ def makePlots():
	#~ for target in ["random","nearby","influentials"]:
		#~ dat = csv2rec("LC_target_%s_hires.stripped.csv"%target)
		#~ for threshold in [0.0001, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.9999]:
			#~ datSubset = dat[dat['mean_grammar']>=threshold]
			#~ figure()			
			#~ make2DHistogram(dat,datSubset,interpolation='nearest',contourLines=0,cmap=modifiedJet)
			#~ title("hi-res target %s, $P(mean final grammar >= %s)$"%(target,threshold))
			#~ savefig("%s_cascadethreshold%s_raw.png"%(target,threshold),dpi=150)
			#~ figure()			
			#~ make2DHistogram(dat,datSubset,interpolation="bilinear",contourLines=0,cmap=modifiedJet)
			#~ title("hi-res target %s, $P(mean final grammar >= %s)$"%(target,threshold))
			#~ savefig("%s_cascadethreshold%s_smooth.png"%(target,threshold),dpi=150)
			#~ figure()			
			#~ make2DHistogram(dat,datSubset,interpolation="bilinear",contourLines=5,cmap=modifiedJet)
			#~ title("hi-res target %s, $P(mean final grammar >= %s)$"%(target,threshold))
			#~ savefig("%s_cascadethreshold%s_smoothlines.png"%(target,threshold),dpi=150)

#~ def makeSubplotFigures():
	#~ dats = {}
	#~ targets = ["random","nearby","influentials"]
	#~ for target in targets:
		#~ dats[target] = csv2rec("LC_target_%s_hires.stripped.csv"%target)
#~ 
	#~ for threshold in [0.0001, 0.5, 0.9, 0.9999]:
		#~ fig = figure(figsize=(8,3.5))
		#~ subplot(1,3,1)
		#~ 
		#~ for i in range(0,len(targets)):
			#~ target = targets[i]
			#~ ax = subplot(1,3,i+1)
			#~ datSubset = dats[target][dats[target]['mean_grammar']>=threshold]
			#~ make2DHistogram(dats[target],datSubset,interpolation='nearest',contourLines=0,showColorBar=(i==2), cmap=modifiedJet)
			#~ if (i>0):
				#~ ax.yaxis.set_ticklabels([])
				#~ ax.yaxis.label.set_text("")
			#~ title("%s"%(fixName(target)))
			#~ subplots_adjust(0.12,0.15,0.87,0.77,0.1,0.2)
		#~ fig.axes[3].set_position([0.89,0.15,0.6,0.62])
		#~ suptitle(r"$P(\bar{g}(t_{final}) \geq %s)$"%threshold, y=0.95,fontsize=16)
		#~ savefig("fig_cascadethreshold%s.pdf"%threshold,dpi=300)
#~ 
#~ def makeSubplotFigures2():
	#~ dats = {}
	#~ targets = ["random","nearby","influentials"]
	#~ for target in targets:
		#~ dats[target] = csv2rec("LC_target_%s_hires.stripped.csv"%target)
#~ 
	#~ for target in targets:
		#~ fig = figure(figsize=(8,3.5))
		#~ subplot(1,3,1)
		#~ 
		#~ for i,threshold,tlabel in [(0,0.0001,"survival"),(1,0.5,"dominance"),(2,0.9999,"completion")]:
			#~ ax = subplot(1,3,i+1)
			#~ datSubset = dats[target][dats[target]['mean_grammar']>=threshold]
			#~ make2DHistogram(dats[target],datSubset,interpolation='nearest',contourLines=0,showColorBar=(i==2),cmap=modifiedJet)
			#~ if (i>0):
				#~ ax.yaxis.set_ticklabels([])
				#~ ax.yaxis.label.set_text("")
			#~ title("%s"%(tlabel))  # r"$P(\bar{g}(t_{final}) \geq %s)$"			
		#~ subplots_adjust(0.12,0.15,0.87,0.77,0.1,0.2)
		#~ fig.axes[3].set_position([0.89,0.15,0.6,0.62])
		#~ suptitle("%s bias distribution"%fixName(target) , y=0.95,fontsize=16)
		#~ savefig("fig_cascades_%s.pdf"%fixName(target),dpi=300)

def makeSubplotFigures3():
	dats = {}
	targets = ["influentials","nearby","random"]
	for target in targets:
		dats[target] = csv2rec("LC_target_%s_hires.stripped.csv"%target)

	fig = figure(figsize=(6.83,6.9))
	for figrow,target in enumerate(targets):
		subplot(3,3,1)
		subplots_adjust(left=0.12,bottom=0.09,right=0.87,top=0.94,wspace=0.2,hspace=0.3)
		
		for i,threshold,tlabel in [(0,0.0001,"survival"),(1,0.5,"dominance"),(2,0.9999,"completion")]:
			ax = subplot(3,3,figrow*3 + i+1)
			datSubset = dats[target][dats[target]['mean_grammar']>=threshold]
			make2DHistogram(dats[target],datSubset,interpolation='nearest',contourLines=0,showColorBar=((i==2) and (figrow==1)),cmap=modifiedJet,label_font_size=16)
			if (i>0):
				ax.yaxis.set_ticklabels([])
				ax.yaxis.label.set_text("")
			xticks(fontsize=10)
			yticks(fontsize=10)
			if (figrow == 0):
				title("%s"%(tlabel), fontsize=12)  # r"$P(\bar{g}(t_{final}) \geq %s)$"			
			if (figrow != 2):
				xlabel("")
		#fig.axes[3].set_position([0.89,0.15,0.6,0.62])
		#suptitle("%s bias distribution"%fixName(target) , y=0.95,fontsize=16)
		#figtext(0.5, [0.68, 0.37, 0.04][figrow], ["a) ","b) ","c) "][figrow] + fixName(target) + " scenario", ha="center", fontsize=9)
                
                my_font = FontProperties()
                my_font.set_weight('bold')
		figtext(0.03, [0.93, 0.62, 0.305][figrow], [r"A",r"B",r"C"][figrow], ha="center", fontsize=18, fontproperties=my_font)
	savefig("grassroots_fig6_2col_updated.pdf")
	savefig("grassroots_fig6_2col_updated.eps")
	savefig("grassroots_fig6_2col_updated.png", dpi=800)
	#~ savefig("fig_cascades_multipanel3.pdf")
	#~ savefig("fig_cascades_multipanel3.eps")
	#~ savefig("fig_cascades_multipanel3.png", dpi=800)



def linearRegressionR2Val(xs,ys):
	"""Returns the R^2 value for a linear regression"""
	return (corrcoef(xs,ys)[0,1])**2

def makeDriftPlot():
	targets = ["random","nearby","influentials"]
	dats = [csv2rec("LC_target_%s.stripped.csv"%target) for target in targets]
	datSubsets = [dat[dat['phi']==45.0] for dat in dats]
	dat45 = concatenate(datSubsets)
	print "Number of runs averaged for each degree = %s"%len(dat45[dat45['degree']==2]) 
	figure(figsize=(3.27,2.4))
	subplots_adjust(left=.18, bottom=.18, top=0.94, right=0.94)
	for threshold,tlabel,col,marker,ms in [(0.0001,"survival","blue","^",6),(0.5,"dominance","green","o",4),(0.9999,"completion","red","v",6)]:
		datThresh = dat45[dat45['mean_grammar']>=threshold]
		b=float64(bincount(datThresh['degree']))
		xs = float64(array(range(len(b))[2:]))
		ys = b[2:] / float(len(dat45[dat45['degree']==2]))
		plot(xs,ys,label=tlabel, color=col, marker=marker,ms=ms*.5,linestyle='None')
		a, b = polyfit(xs,ys,1)
		yRegress = polyval([a,b],xs)
		plot(xs[[0,-1]],yRegress[[0,-1]],':',color=col,marker='None')
		r2 = linearRegressionR2Val(xs,ys)
		text(xs[40]-3,yRegress[40]+0.004,r"$R^2 \approx %.2f$"%r2,fontsize=8,color=col,ha='right',zorder=10)
	pylab.rcParams["legend.fontsize"] = 10
	legend(loc="upper left",numpoints=1,handlelength=1,handletextpad=0.5,markerscale=1.5)
	ylim(-0.005,0.14)
	xlim(0,56)
	xticks(fontsize=9)	
	yticks(fontsize=9)	
	xlabel("innovator degree",fontsize=12)
	ylabel("Probability",fontsize=12)
	#title(r"`Drifting' cascades ($\phi = 45$)")
	savefig("grassroots_fig5_updated2.png",dpi=800)
	savefig("grassroots_fig5_updated2.pdf")
	savefig("grassroots_fig5_updated2.eps")
	#~ savefig("fig_driftingcascades.png",dpi=800)
	#~ savefig("fig_driftingcascades.pdf")
	#~ savefig("fig_driftingcascades.eps")



#~ def makeChangeFromBelowPlots():
	#~ dat = csv2rec("LC_target_nearby_finegamma.stripped.csv")
	#~ dat60 = dat[dat['phi']==60.0]
	#~ degreeDist = loadtxt("degree_dist_from_450000_256_node_networks.txt")[:,1]
	#~ degreePDF = degreeDist / sum(degreeDist)
	#~ numSimulationsPerDegree = float(len(dat60[dat60['degree']==2]))
	#~ print "Number of runs averaged for each degree = %s"%numSimulationsPerDegree
	#~ for plotChoice in ["p(c|d)","p(d|c)","p(c) vs deg"]:
		#~ figure()
		#~ for threshold,tlabel,col,marker,ms in [(0.0001,"survival","blue","^",6),(0.5,"dominance","green","D",4),(0.9999,"completion","red","*",6)]:
			#~ datThresh = dat60[dat60['mean_grammar']>=threshold]
			#~ b=float64(bincount(datThresh['degree']))
			#~ xs = float64(array(range(len(b))[2:]))
			#~ ys = b[2:] / numSimulationsPerDegree
			#~ if plotChoice != "p(c|d)":
				#~ ys = ys * degreePDF[2:56] 
				#~ if plotChoice == "p(d|c)":
					#~ ys = ys / sum(b / numSimulationsPerDegree * degreePDF[:56] )
					#~ print "p(c|d): sum(ys)=%s (should be close to 1)"%sum(ys)
			#~ plot(xs,ys,label=tlabel, color=col, marker=marker,ms=ms)#,linestyle='None')
		#~ #ylim(-0.005,0.14)
		#~ xlim(0,56)
		#~ xticks(fontsize=14)	
		#~ yticks(fontsize=14)	
		#~ xlabel("innovator degree",fontsize=15)
		#~ if plotChoice=="p(c|d)":
			#~ legend(loc="lower right",numpoints=1,handlelength=1,handletextpad=0.5,markerscale=1.5)
			#~ ylabel(r"P(cascade$\vert$degree)",fontsize=15)
			#~ #title(r"\textit{nearby} bias distribution, $\phi = 60$")
			#~ savefig("fig_nearby_phi60_p_cascade_given_degree.pdf",dpi=300)
		#~ elif plotChoice=="p(d|c)":
			#~ legend(loc="upper right",numpoints=1,handlelength=1,handletextpad=0.5,markerscale=1.5)
			#~ ylabel(r"P(degree$\vert$cascade)",fontsize=15)  #*
			#~ #title(r"\textit{nearby} bias distribution, $\phi = 60$")
			#~ savefig("fig_nearby_phi60_p_degree_given_cascade.pdf",dpi=300)
		#~ else:
			#~ legend(loc="upper right",numpoints=1,handlelength=1,handletextpad=0.5,markerscale=1.5)
			#~ ylabel(r"P(cascade)",fontsize=15)  #*
			#~ #title(r"\textit{nearby} bias distribution, $\phi = 60$")
			#~ savefig("fig_nearby_phi60_p_cascade_versus_degree.pdf",dpi=300)

def makeChangeFromBelowPlot():
	dat = csv2rec("LC_target_nearby_finegamma.stripped.csv")
	dat60 = dat[dat['phi']==60.0]
	degreeDist = loadtxt("degree_dist_from_450000_256_node_networks.txt")[:,1]
	degreePDF = degreeDist / sum(degreeDist)
	numSimulationsPerDegree = float(len(dat60[dat60['degree']==2]))
	print "Number of runs averaged for each degree = %s"%numSimulationsPerDegree
	figure(figsize=(3.27,2.3))
	subplots_adjust(left=.15, bottom=.17, top=0.94, right=0.94)
	for plotChoice, lineLabel, fmtStr in [("p(c|d)",r"P(cascade$\vert$degree)", "rv-"), ("p(d|c)",r"P(degree$\vert$cascade)", "b^-")]:
		threshold = 0.9999 # i.e. "completion"
		datThresh = dat60[dat60['mean_grammar']>=threshold]
		b=float64(bincount(datThresh['degree']))
		xs = float64(array(range(len(b))[2:]))
		ys = b[2:] / numSimulationsPerDegree
		if plotChoice != "p(c|d)":
			ys = ys * degreePDF[2:56] 
			if plotChoice == "p(d|c)":
				ys = ys / sum(b / numSimulationsPerDegree * degreePDF[:56] )
				print "p(c|d): sum(ys)=%s (should be close to 1)"%sum(ys)
		plot(xs,ys,fmtStr,label=lineLabel)#,linestyle='None')
		#ylim(-0.005,0.14)
		xlim(0,56)
		xticks(fontsize=8)	
		yticks(fontsize=8)	
		xlabel("innovator degree",fontsize=10)
		ylabel("Probability",fontsize=10)
		pylab.rcParams["legend.fontsize"] = 10
		legend(loc="upper left",bbox_to_anchor=(0.35,0.4),numpoints=1,handlelength=1,handletextpad=0.5,markerscale=1.0)
		#title(r"\textit{nearby} bias distribution, $\phi = 60$, using completion (0.9999) criterion")
		savefig("grassroots_fig7_updated.pdf")
		savefig("grassroots_fig7_updated.eps")
		savefig("grassroots_fig7_updated.png",dpi=800)
		#~ savefig("fig_nearby_phi60_p_degree_and_p_cascade.pdf")
		#~ savefig("fig_nearby_phi60_p_degree_and_p_cascade.eps")
		#~ savefig("fig_nearby_phi60_p_degree_and_p_cascade.png",dpi=800)

#~ def makeChangeFromBelowHistograms():
	#~ dat = csv2rec("LC_target_nearby_finegamma.stripped.csv")
	#~ dat60 = dat[dat['phi']==60.0]
	#~ print "Number of runs averaged for each degree = %s"%len(dat60[dat60['degree']==4]) 
#~ 
	#~ figure()
#~ 
	#~ hist([dat60[dat60['degree']==10]['mean_grammar'],dat60[dat60['degree']==55]['mean_grammar']],label=['innovator degree = 10','innovator degree = 55'],weights=[[(1/1000.0)]*1000]*2,color=['red','blue'],ec='None',rwidth=1,bins=40)
#~ 
	#~ xticks(fontsize=14)	
	#~ yticks(fontsize=14)	
	#~ xlabel("mean final grammar state",fontsize=15)
	#~ ylabel("frequency",fontsize=15)
	#~ title(r"\textit{nearby} bias distribution, $\phi = 60$")
	#~ legend(loc='upper left')
	#~ savefig("fig_nearby_phi60_end_state_histogram.pdf",dpi=300)



def colormapTest():
	threshold = 0.8
	target = "nearby"
	dat = csv2rec("LC_target_%s_hires.stripped.csv"%target)
	for cmap in [ cm.autumn, cm.bone, cm.cool, cm.copper, cm.flag, cm.gray, cm.hot, cm.hsv, cm.jet, cm.pink, cm.prism, cm.spring, cm.summer, cm.winter, cm.spectral ]:
		datSubset = dat[dat['mean_grammar']>=threshold]
		figure()			
		make2DHistogram(dat,datSubset,interpolation='bilinear',contourLines=0,cmap=cmap)
		title("hi-res target %s, $P(mean final grammar >= %s)$ [%s]"%(target,threshold,cmap.name))
		savefig("colorstest_%s.png"%cmap.name,dpi=150)

###makePlots()
###makeSubplotFigures()
###makeSubplotFigures2()

#makeSubplotFigures3()

makeDriftPlot()
#makeChangeFromBelowPlot()

#makeChangeFromBelowHistograms() #not used in paper?

###make2DHistogram("LC_target_influentials_hires.stripped.csv","hi-res target influentials, $P(mean final grammar >= 0.0001)$")
###make2DHistogram("LC_target_nearby_hires.stripped.csv","hi-res target nearby, $P(mean final grammar >= 0.0001)$")




