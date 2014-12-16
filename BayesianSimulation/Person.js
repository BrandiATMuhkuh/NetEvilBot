/**
 * Created by jbr134 on 16/12/14.
 */

/**
 * The class person describes one person in the network.
 * Each person has it's own "brain". By interacting with the other people in the network
 * the person learns how others call words.
 * @param {string} myName The name of the person
 * @constructor
 */

var brain = require("brain");

var Person = function (myName) {
    this.myName = myName;
    this.training = [];
    this.myBrain = new brain.NeuralNetwork();

    /**
     * Train the person.
     * It's important to notice that the neural network is recreated each time the person
     * is trained. The reason is that the system I use (npm install brain) does it in this way.
     * @param {string} image Name of the image
     * @param {string} partnerName The partners name
     * @param {string} partnerImageName How the partner names the image
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
     * The persons guess what it's partner used for an image.
     * Returns an array with probabilities.
     * @param {string} image Name of the image
     * @param {string} partnerName The partners name
     */
    this.guess = function(image, partnerName){
        var i = {};
        i[image] = 1;
        i[partnerName] = 1;
        console.log(this.myBrain.run(i));
    };
};

module.exports = Person;