from snap import *
import snap

def consGraph(g):
    for EI in g.Edges():
        print "edge: (%d, %d)" % (EI.GetSrcNId(), EI.GetDstNId())

def n2img(g):
    labels = snap.TIntStrH()
    for NI in G1.Nodes():
            labels[NI.GetId()] = str(NI.GetId())
    snap.DrawGViz(G1, snap.gvlDot, "output.png", " ", labels)

nSize = 5 #Network size
G1 = PUNGraph.New()

#G1 = LoadEdgeList(PNGraph, "Email-Enron.txt", 0, 1)
G1 = snap.GenFull(snap.PUNGraph, nSize)
#G1 = snap.GenCircle(snap.PUNGraph, nSize)
#G1 = snap.GenGrid(snap.PUNGraph, 3, 3, False)
G1 = snap.GenStar(snap.PUNGraph, nSize, False)
G1 = snap.GenTree(snap.PNGraph, 2, 2)
G1 = snap.GenRndGnm(snap.PUNGraph, nSize, nSize*2, False)
G1 = snap.GenPrefAttach(10, 3)
G1 = snap.GenGeoPrefAttach(20, 5, 0.25,)
G1 = snap.GenSmallWorld(10, 3, 0, snap.TRnd(1,0))

n2img(G1)
consGraph(G1)
