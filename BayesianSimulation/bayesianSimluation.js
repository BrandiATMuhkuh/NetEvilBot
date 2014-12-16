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
var nodes = 3; //The nodes/people of the network


//All possible images in the network
var images = [
    "image0",
    "image1",
    "image2"];

//All possible words in the network
var words = [
    "fish",
    "dog",
    "cat"];


//All possible users in the network
var users = [];





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

initTrainingData = initTrainingSet(images, nodes, words);

//create initial person. We close it later for performance reasons
var dolly = new Person("Dolly");
dolly.training = initTrainingData;
//run initial training
dolly.init();


for (i = 0; i < nodes; i++) { //We clone 5 people
    var notDollyAgain = clone(dolly);
    notDollyAgain.myName = "person" + i;

    users.push(notDollyAgain);
}



users[0].guess("image0", "dolly0");
users[1].guess("image0", "dolly0");
users[2].guess("image0", "dolly0");
