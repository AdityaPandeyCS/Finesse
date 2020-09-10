const {body, validationResult} = require("express-validator");

const Future = require("../model/future");
const User = require("../model/user");
const agenda = require("../agenda.js");

exports.getEvents = function (req, res) {
    console.log('getting future');
    Future.find({}).sort('startTime').exec(function (err, listEvents) {
        if (err) {
            res.status(400).end();
        }
        res.json(listEvents);
    });
};

exports.addEvent = async function (req, res, next) {
    const {
        eventTitle,
        emailId,
        school,
        description,
        location,
        isActive,
        image,
        startTime,
        endTime,
        repetition,
        category,
        points,
        numComments,
    } = req.body;

    let startDate = new Date(startTime);
    let endDate = endTime ? new Date(endTime) : undefined;
    let eventjson = {
        eventTitle: eventTitle,
        emailId: emailId,
        school: school,
        description: description,
        location: location,
        isActive: isActive,
        image: image,
        startTime: startDate,
        endTime: endDate,
        repetition: repetition,
        category: category,
        points: points,
        numComments: numComments,
    };
    if (emailId === "test") {
        eventjson.createdAt = new Date();
    }

    let newEvent = new Future(eventjson);
    let newId = newEvent._id.toString();
    await newEvent.save(function (err) {
        if (err) {
            return next(err);
        }
        let logMessage = "Success: added new event = " + eventTitle;
        console.log(logMessage);
        res.send({msg: logMessage, id: newId});

        agenda.schedule(startDate, 'start event', newEvent);
    });

    let user = await User.findOne({emailId: emailId});
    user.upvoted.push(newId);
    user.subscriptions.push(newId);
    await user.save(function (err) {
        if (err) {
            console.log("error adding post to upvoted - " + err);
            return next(err);
        }
        let logMessage = "Success: set votes for user = " + emailId;
        console.log(logMessage);
    });
};

exports.updateEvent = async (req, res, next) => {
    const eventId = req.params.eventId;
    const {
        eventTitle,
        emailId,
        school,
        description,
        location,
        isActive,
        image,
        startTime,
        endTime,
        repetition,
        category,
        points,
        numComments,
    } = req.body;

    try {
        let currEvent = await Future.findOne({_id: eventId});
        if (points !== currEvent.points) {
            let author = await User.findOne({emailId: emailId});
            author.points += points - currEvent.points;
            author.save();
        }

        currEvent.eventTitle = eventTitle;
        currEvent.emailId = emailId;
        currEvent.school = school;
        currEvent.description = description;
        currEvent.location = location;
        currEvent.isActive = isActive;
        currEvent.image = image;
        currEvent.startTime = new Date(startTime),
        currEvent.endTime = new Date(endTime),
        currEvent.repetition = repetition,
        currEvent.category = category;
        currEvent.points = points;
        currEvent.numComments = numComments;
        await currEvent.save(function (err) {
            if (err) {
                return next(err);
            }
            let logMessage = "Success: updated event _id = " + eventId;
            console.log(logMessage);
            res.send(logMessage);
        });
    } catch (err) {
        console.log("Error: unable to update event/author = ", eventId, emailId);
        console.log(err);
        res.status(400).end();
    }
};

exports.deleteEvent = function (req, res) {
    let eventId = req.params.eventId;
    Future.findByIdAndDelete(eventId, function (err) {
        if (err) {
            res.status(400).end();
        } else {
            let logMessage = "Success: deleted event _id = " + eventId;
            console.log(logMessage);
            res.send(logMessage);
        }
    });
};
