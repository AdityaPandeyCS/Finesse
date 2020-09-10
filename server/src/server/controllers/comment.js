const { body, validationResult } = require("express-validator");
const axios = require('axios');

const Comment = require("../model/comment");
const Event = require("../model/event");

exports.getComments = function (req, res) {
    let eventId = req.params.eventId;

    Comment.find({ "eventId": eventId }).exec(function (err, listComments) {
        if (err) { res.status(400).end(); }
        res.json(listComments);
    });
};

exports.addComment = [
    // Validate fields
    body("eventId", "Please enter a valid event id").isLength({ min: 1 }).trim(),
    body("emailId", "Please enter a valid email address").isLength({ min: 1 }).trim(),
    body("comment", "The comment cannot be empty").isLength({ min: 1 }).trim(),
    body("postedTime", "The time cannot be empty").isLength({ min: 1 }).trim(),

    async (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            console.log("Error Happened");
            return res.status(400).json({
                errors: errors.array()
            });
        }
        const { eventId, emailId, comment, postedTime } = req.body;
        let commentjson = {
            "eventId": eventId,
            "emailId": emailId,
            "comment": comment,
            "postedTime": postedTime,
        };
        if (emailId == 'test') {
            commentjson.createdAt = new Date();
        }
        let newComment = new Comment(commentjson);
        var logMessage = "";
        await newComment.save(function (err) {
            if (err) { return next(err); }
            logMessage += "Success: added new comment = " + comment;
        });

        let currEvent = await Event.findOne({ "_id": eventId });
        currEvent.numComments++;
        await currEvent.save(function (err) {
            if (err) { return next(err); }
            else {
                logMessage += "\nSuccess: updated event _id = " + eventId;
                console.log(logMessage);
                res.send(logMessage);

                let title = currEvent.eventTitle;
                let body = emailId.split('@')[0] + ': ' + comment;
                let content = {
                    'notification': {
                        'title': title,
                        'body': body
                    },
                    'priority': 'high',
                    'data': {
                        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                        'status': 'done',
                        'id': eventId,
                        'type': 'comment',
                        'author': emailId,
                        'title': title,
                        'body': body
                    },
                    'to': '/topics/' + eventId
                };
                let config = {
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'key=' + process.env.FINESSE_SERVER_KEY,
                    }
                };
                axios.post('https://fcm.googleapis.com/fcm/send', content, config)
                    .then(function (response) {
                        console.log('sent notification', content.notification);
                    })
                    .catch(function (error) {
                        console.log(error);
                    });
            }
        });
    }
];
