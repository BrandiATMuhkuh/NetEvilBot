print("start")
print("next")
from random import randint
import random
import time

startTime  = int(round(time.time() * 1000))


class Turtle:
    def __init__(self, id):
        self.id = id
        self.links = []
        self.dictionary = []

    def addLink(self, link):
        #print("addLink")
        self.links.append(link)

    def myGuess(self):
        if len(self.dictionary) == 0:
            self.dictionary.append(randint(0,100000))
        return random.choice (self.dictionary)

    def theOtherOneSaid(self, said):

        if said in self.dictionary:
            self.dictionary = []
        self.dictionary.append(said)


class Link:
    def __init__(self, turtle1, turtle2):
        #print(turtle1.id,turtle2.id)
        self.turtle1 = turtle1
        self.turtle2 = turtle2
        self.turtle1.addLink(self);
        self.turtle2.addLink(self);

class ExperimentalGenerator:
    def __init__(self, numberOfNotes):
        self.n = numberOfNotes;
        self.turtles = [];
        self.links = [];
        self.threshold = 100;
        #print(self.n)

        self.generateTurles()
        self.linkTurtles()

        print "setup time: ", (int(round(time.time() * 1000)) - startTime), "ms"
        self.experiment()


    def generateTurles(self):
        for i in range(self.n):
            #print i
            self.turtles.append(Turtle(i))

    def linkTurtles(self):
        #print("li")
        cut = 0

        for i in self.turtles:
            for k in self.turtles[cut:]:
                if i.id != k.id:
                    self.links.append(Link(i,k))
                #print i.id

            cut = cut + 1

    def experiment(self):
        print("exp")

        while self.equilibrium() == False:
            #print (a)
            temp = random.choice (self.links)
            t1 = temp.turtle1
            t2 = temp.turtle2
            g1 = t1.myGuess()
            g2 = t2.myGuess()
            t1.theOtherOneSaid(g2)
            t2.theOtherOneSaid(g1)

    def sumOfDict(self):
        sum = 0
        for i in self.turtles:
            sum = sum + len(i.dictionary)

        return sum

    def equilibrium(self):
        if (self.sumOfDict() / len(self.turtles)) == 1:
            for i in self.turtles:
                for k in self.turtles:
                    if len(i.dictionary) == 0:

                        return False
                    if len(k.dictionary) == 0:

                        return False

                    if i.dictionary[0] != k.dictionary[0]:
                        return False
            return True

        return False



ExperimentalGenerator(10000)
print "done: ", (int(round(time.time() * 1000)) - startTime), "ms"
