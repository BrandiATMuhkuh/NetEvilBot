"use strict";

let startTime = Date.now();

Array.prototype.random = function () {
  return this[Math.floor((Math.random()*this.length))];
}



class Turtle{
  constructor(id){
    this.id=id;
    this.links = [];
    this.dictionary = [];
  }

  addLink(link){
    //check if this link already exists
    this.links.push(link);
  }

  myGuess(){

    //If dictionary is zero add something
    if(this.dictionary.length === 0){
      this.dictionary.push(Math.round(Math.random()*1000000));
    }
    return this.dictionary.random();
  }

  theOtherOneSaid(said){

    if(this.dictionary.indexOf(said) !== -1){//found in dict
      this.dictionary = []; // Empty dictionary since we have the same word in our dict
    }
    this.dictionary.push(said);
  }

}

class Link{
  constructor(turtle1, turtle2){
    this.turtle1 = turtle1;
    this.turtle2 = turtle2;
    this.turtle1.addLink(this);
    this.turtle2.addLink(this);
  }
}



class ExperimentalGenerator{
  constructor(numberOfNotes){
    this.n = numberOfNotes;
    this.turtles = [];
    this.links = [];
    this.threshold = 100;

    this.generateTurles();
    this.linkTurtles();

    console.log("setup time: ", (Date.now() - startTime) + "ms");

    //console.log(this.links.length);
    //console.log(this.turtles.map(function (i) { return i.links.length }));
    this.experiment();
  }

  generateTurles(){

    // Generate turles
    for(let i=0; i<this.n; i=i+1){
      this.turtles.push(new Turtle(i));
    }
  }

  linkTurtles(){
    //console.log("linkTurtles");

    for(let i=0; i<this.turtles.length; i=i+1){
      for(let k=i; k<this.turtles.length; k=k+1){
        if(i!=k){ //Make sure a Turtle is not linked to itself
          //console.log(i,k);
          this.links.push(new Link(this.turtles[i],this.turtles[k]));
        }
      }
    }
  }

  experiment(){
    console.log("start experiment");

    let stop = 0;
    let temp = null;
    let t1 = null;
    let t2 = null;
    let g1 = null;
    let g2 = null;
    while(!this.equilibrium()){
      stop = stop + 1;
      temp = this.links.random();
      t1 = temp.turtle1;
      t2 = temp.turtle2;
      g1 = t1.myGuess();
      g2 = t2.myGuess();
      t1.theOtherOneSaid(g2);
      t2.theOtherOneSaid(g1);

      //console.log(this.sumOfDict(), this.equilibrium());
    }

  }

  sumOfDict(){
    let sum = 0;
    for(let i=0; i<this.turtles.length; i=i+1){
      sum = sum + this.turtles[i].dictionary.length;
    }
    return sum;
  }

  equilibrium(){

    if(this.sumOfDict() / this.turtles.length === 1){//check if the sum of dictionary is the size of all turtles

      //check if all turles have the same value in the dicts
      for(let i=0; i<this.turtles.length; i=i+1){
        for(let k=0; k<this.turtles.length; k=k+1){
          if(this.turtles[i].dictionary[0] !== this.turtles[k].dictionary[0]){
            return false;
          }
        }
      }
      return true;
    }

    return false;
  }


}

new ExperimentalGenerator(1000);
console.log("done: ", (Date.now() - startTime) + "ms");

//console.log(l1.turtle1);
