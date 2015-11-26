import networkx as nx
import matplotlib.pyplot as plt
import d3py
import numpy as np
from random import randint
from time import sleep

nStub = 5
stubWord = "abc"
G = nx.Graph(day="Friday")

G=nx.complete_graph(100)

nx.set_node_attributes(G, 'stubbern', False)
nx.set_node_attributes(G, 'dictionary', [])
#G.add_node(1, dictionary=[])
#G.add_node(1, stubbern=False)
#G.edges(data=True)

#G=nx.lollipop_graph(10,20)
#G=nx.watts_strogatz_graph(30,3,0.1)

#G.add_edges_from([(1,2),(2,3),(3,4),(4,1)])
#G.add_edges_from([(1,2),(1,3)])

def randomCouple():
    n1 = randint(0,G.number_of_nodes()-1)
    n2 = randint(0,len(G.neighbors(n1)))
    #print ("randNode", n1)
    #print ("randNeigmor", n2)

    return [G.node[n1],G.node[n2]]

def createStubbernPeople(n, diction):
    if G.number_of_nodes() < n:
        return
    i = 0

    while(i<n):
        #print i
        temp = G.node[(randint(0,G.number_of_nodes()-1))]
        if temp["stubbern"] == False:
            #print ("bef temp", temp)
            temp["stubbern"] = True
            temp["dictionary"] = [diction]
            #print ("aft temp", temp)
            i = i + 1



def talk(couple):

    if len(couple[0]["dictionary"]) == 0:
        couple[0]["dictionary"] = [str(randint(10,100000))]

    if len(couple[1]["dictionary"]) == 0:
        couple[1]["dictionary"] = [str(randint(10,100000))]

    word1 = couple[0]["dictionary"][randint(0,len(couple[0]["dictionary"])-1)]

    #print couple[0]["dictionary"], " said ", word1, "to ", couple[1]["dictionary"]

    updateDict(couple[0],word1)
    updateDict(couple[1],word1)

    #print ("lets talk")

def updateDict(node, word):
    if node["stubbern"]:
        return
    if word in node["dictionary"]:
        node["dictionary"] = [word]
    else:
        node["dictionary"].append(word)

def totalWord():
    sum = 0
    wordList = [];
    for i,p in G.nodes(True):
        sum = sum + len(p["dictionary"])
        wordList = wordList + p["dictionary"]

    hist =  dict((x, wordList.count(x)) for x in wordList)
    relWords = len(hist.keys())
    return sum,wordList,hist,relWords

def saveHist():
    data =  totalWord()[1]

    author_names = counter.keys()
    author_counts = counter.values()
    indexes = np.arange(len(author_names))
    width = 0.7
    plt.bar(indexes, author_counts, width)
    plt.xticks(indexes + width * 0.8, author_names)
    #plt.show()

    #nx.draw_networkx(G)
    #nx.draw_random(G)
    #nx.draw_circular(G)
    #nx.draw_spectral(G)
    #nx.draw_graphviz(G)
    #nx.write_dot(G,'file.dot')
    plt.savefig("output.png")
    #plt.show()

def printBar(n):
    b = ""
    for i in range(0,n):
        b = b + "-"

    return b

'''
print('number_of_nodes', G.number_of_nodes())
print('number_of_edges', G.number_of_edges())
#print(G.nodes())
randNeigmor = randint(0,len(G.neighbors(3)))
print(G.neighbors(randNeigmor))
print(G.node[3])
print(G.edge[0])
print(G.edge[3])
'''
createStubbernPeople(2, "abc")
tw = totalWord()
i = 0
while tw[3] > 1 or i < 10:
    talk(randomCouple())
    tw = totalWord()
    i = i + 1
    #print printBar(tw[3]), tw[3], i
    #sleep(0.05)
    if i % 500 == 0:
        print i, tw[3]
        sleep(0.2)
    #data =  totalWord()[1]
    #print dict((x, data.count(x)) for x in data)

#saveHist()
#print (G.node)






"""
with d3py.NetworkXFigure(G, name="graph",width=1000, height=1000) as p:
    p += d3py.ForceLayout()
    p.css['.node'] = {'fill': 'blue', 'stroke': 'magenta'}
    #p.save_to_files()
    p.show()
"""
