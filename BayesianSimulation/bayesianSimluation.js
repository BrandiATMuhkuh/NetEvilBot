/**
 * Created by jbr134 on 16/12/14.
 */
/**
 * IMPORTANT:
 * 1: All data needs to be between 0 and 1
 * 2: All data needs to be trained in bulk. --> recreate of NeuralNetwork object --> expensive I know
 */
var clone = require("clone");
var Person = require("./Person.js");
var nodes = 10; //The nodes/people of the network


//All possible images in the network
var images = [
    "image0",
    "image1",
    "image2",
    "image4"];

//All possible words in the network
var words = [
    "fish",
    "dog",
    "cat",
    "crocodile"];


//All possible users in the network
var users = [];

var randArrayElement = function(arr){
    return arr[Math.floor(Math.random()*arr.length)];
}



var initTrainingSet = function (image, partnerName, partnerImageName) {
    console.log("time to create a training set");

    var initArray = [];

    image.forEach(function (im) {
        partnerImageName.forEach(function (wo) {
            for (no = 0; no < partnerName; no++) {
                var i = {};
                i[im] = 1;

                i["person" + no] = 1;
                var o = {};
                o[wo] = 1;
                var t = {input: i, output: o};

                initArray.push(t);

            }
        })
    });

    return initArray;

}

var printNetworkState = function(state, person, image){
    var cvs = "";
    cvs += "" + state + ", person" + person + ", " + image + ", ";
    for (no = 0; no < nodes; no++) {
        var gf = users[person].guessFirst(image, "person" + no);
        var g = users[person].guess(image, "person" + no);

        if(person != no) {
            cvs += "person" + no + ", " + gf +", "+ g[gf]+", ";
        }

    }
    cvs+= "\n";
    return cvs;
}

initTrainingData = initTrainingSet(images, nodes, words);

//create initial person. We close it later for performance reasons
var dolly = new Person("Dolly");
dolly.training = initTrainingData;
//run initial training
//dolly.init();


for (var i = 0; i < nodes; i++) { //We clone 5 people
    var notDollyAgain = clone(dolly);
    notDollyAgain.myName = "person" + i;
    notDollyAgain.init();
    users.push(notDollyAgain);
}

var mycvs = "";
for(var i = 0; i < 50; i++) {
    var randImage = randArrayElement(images);
    var randUser1 = randArrayElement(users);
    var randUser2 = randArrayElement(users);

    do {
        randUser2 = randArrayElement(users);
    } while (randUser1.myName == randUser2.myName);

    var ua1 = randUser1.guessFirst(randImage, randUser2.myName);
    var ua2 = randUser2.guessFirst(randImage, randUser1.myName);
    //console.log(randUser1.myName, ua1, randUser2.myName, ua2);


    //Print CSV type output at network state x
    for (var k = 0; k < nodes; k++) {
       mycvs += printNetworkState(i, k, "image0");
    }

    randUser1.addTraining(randImage, randUser2.myName, ua2);
    randUser2.addTraining(randImage, randUser1.myName, ua1);



}
console.log(mycvs);