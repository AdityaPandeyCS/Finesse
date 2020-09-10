const {body, validationResult} = require("express-validator");
const axios = require('axios');

const Event = require("../model/event");
const User = require("../model/user");
const agenda = require("../agenda.js");

exports.getEvents = function (req, res) {
    Event.find({}).exec(function (err, listEvents) {
        if (err) {
            res.status(400).end();
        }
        res.json(listEvents);
    });
};

exports.getEvent = function (req, res) {
    let eventId = req.params.eventId;
    console.log(eventId);
    Event.findOne({_id: eventId}).exec(function (err, event) {
        if (err) {
            res.status(400).end();
        } else {
            res.json(event);
        }
    });
};

exports.addEvent = [
    // Validate fields
    body("eventTitle", "Please enter a valid event title")
        .isLength({min: 1})
        .trim(),
    body("location", "Please enter a valid location").isLength({min: 1}).trim(),
    body("startTime", "Please enter a valid start time")
        .isLength({min: 1})
        .trim(),

    async (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            console.log("Error Happened");
            return res.status(400).json({
                errors: errors.array(),
            });
        }

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
            duration,
            category,
            points,
            numComments,
        } = req.body;

        let endDate = endTime ? new Date(endTime) : undefined;
        let eventjson = {
            eventTitle: eventTitle,
            emailId: emailId,
            school: school,
            description: description,
            location: location,
            isActive: isActive,
            image: image,
            startTime: new Date(startTime),
            endTime: endDate,
            duration: duration,
            category: category,
            points: points,
            numComments: numComments,
        };
        if (emailId === "test") {
            eventjson.createdAt = new Date();
        }

        let newEvent = new Event(eventjson);
        let newId = newEvent._id.toString();
        await newEvent.save(function (err) {
            if (err) {
                return next(err);
            }
            let logMessage = "Success: added new event = " + eventTitle;
            console.log(logMessage);
            res.send({msg: logMessage, id: newId});

            if (endDate) {
                console.log('about to schedule end event');
                agenda.schedule(endDate, 'end event', newEvent);
            }

            let content = {
                'notification': {
                    'title': eventTitle,
                    'body': location
                },
                'priority': 'high',
                'data': {
                    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                    'status': 'done',
                    'id': newId,
                    'type': 'post',
                    'author': emailId,
                    'title': eventTitle,
                    'body': location
                },
                'to': '/topics/newpost'
            };
            let config = {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'key=' + process.env.FINESSE_SERVER_KEY,
                }
            };
            axios.post('https://fcm.googleapis.com/fcm/send', content, config)
                .then(function () {
                    console.log('sent notification', content.notification);
                })
                .catch(function (error) {
                    console.log(error);
                });
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
    },
];

exports.updateEvent = [
    // Validate fields
    body("eventId", "Please enter a valid event id").isLength({min: 24}).trim(),
    body("eventTitle", "Please enter a valid event title")
        .isLength({min: 1})
        .trim(),
    body("location", "Please enter a valid location").isLength({min: 1}).trim(),
    body("startTime", "Please enter a valid start time")
        .isLength({min: 1})
        .trim(),
    body("location", "Please enter a valid location").isLength({min: 1}).trim(),

    async (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            console.log("Error Happened");
            return res.status(400).json({
                errors: errors.array(),
            });
        }

        const {
            eventId,
            eventTitle,
            emailId,
            school,
            description,
            location,
            isActive,
            image,
            startTime,
            duration,
            category,
            points,
            numComments,
        } = req.body;

        try {
            let currEvent = await Event.findOne({_id: eventId});
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
            currEvent.startTime = new Date(startTime);
            currEvent.duration = duration;
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
    },
];

exports.deleteEvent = function (req, res) {
    let rawEventId = req.body.eventId;
    Event.findByIdAndDelete(rawEventId, function (err) {
        if (err) {
            res.status(400).end();
        } else {
            let logMessage = "Success: deleted event _id = " + rawEventId;
            console.log(logMessage);
            res.send(logMessage);
        }
    });
};
