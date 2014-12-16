/**
 * Created by jbr134 on 16/12/14.
 */
console.log("lets start");

var brain = require("brain");

/**
 * IMPORTANT:
 * 1: All data needs to be between 0 and 1
 * 2: All data needs to be trained in bulk. --> recreate of NeuralNetwork object --> expensive I know
 */


var images = [
    "image1",
    "image2",
    "image3",
    "image4",
    "image5",
    "image6",
    "image7",
    "image8",
    "image9",
    "image10"]; //All possible images in the network


var words = [
    "fish",
    "dog",
    "cat",
    "chicken",
    "sheep",
    "ape",
    "human",
    "snake"]; //All possible words in the network


var users = []; //All possible users in the network


/**
 * The class person describes one person in the network.
 * Each person has it's own "brain". By interacting with the other people in the network
 * the person learns how others call words.
 * @param myName The name of the person
 * @constructor
 */
var Person = function (myName) {
    this.myName = myName;
    this.training = [];
    this.myBrain = new brain.NeuralNetwork();

    /**
     * Train the person.
     * It's important to notice that the neural network is recreated each time the person
     * is trained. The reason is that the system I use (npm install brain) does it in this way.
     * @param image Name of the image
     * @param partnerName The partners name
     * @param partnerImageName How the partner names the image
     */
    this.addTraining = function(image, partnerName, partnerImageName){
        var o = {};
        o[partnerImageName] = 1;
        var i = {};
        i[image] = 1;
        i[partnerName] = 1;

        var t = {input: i, output: o};
        //console.log(t);

        this.training.push(t);
        this.myBrain = new brain.NeuralNetwork(); //This system uses BULK training. Sorry ;(
        this.myBrain.train(this.training);
    };

    /**
     * The
     * @param image
     * @param imageName
     */
    this.guess = function(image, partnerName){
        var i = {};
        i[image] = 1;
        i[partnerName] = 1;
        console.log(this.myBrain.run(i));
    };
};


var person2 = new Person("user2");
person2.addTraining("zero1", "zero2", "zero");
person2.addTraining("zero1", "one2", "one");
person2.addTraining("one1", "zero2", "one");
person2.addTraining("one1", "one2", "zero");
person2.addTraining("one1", "one2", "zero");


person2.guess("zero1", "zero2");
person2.guess("zero1", "one2");
person2.guess("one1", "zero2");
person2.guess("one1", "one2");
