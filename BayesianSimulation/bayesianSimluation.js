/**
 * Created by jbr134 on 16/12/14.
 */
/**
 * IMPORTANT:
 * 1: All data needs to be between 0 and 1
 * 2: All data needs to be trained in bulk. --> recreate of NeuralNetwork object --> expensive I know
 */
var Person = require("./Person.js");


//All possible images in the network
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
    "image10"];

//All possible words in the network
var words = [
    "fish",
    "dog",
    "cat",
    "chicken",
    "sheep",
    "ape",
    "human",
    "snake"];


//All possible users in the network
var users = [
    new Person("user1"),
    new Person("user2"),
    new Person("user3"),
    new Person("user4"),
    new Person("user5"),
    new Person("user6")
];





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
