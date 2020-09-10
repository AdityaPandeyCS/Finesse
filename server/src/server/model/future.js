const mongoose = require("mongoose"),

    FutureSchema = mongoose.Schema({

        "eventTitle": {
            "type": String,
            "required": true
        },
        "emailId": {
            "type": String,
            "required": true
        },
        "school": {
            "type": String,
            "required": true
        },
        "description": {
            "type": String,
            "required": false
        },
        "location": {
            "type": String,
            "required": true
        },
        "isActive": {
            "type": [String],
            "required": false
        },
        "image": {
            "type": String,
            "required": false
        },
        "category": {
            "type": String,
            "required": false
        },
        "points": {
            "type": Number,
            "required": true
        },
        "numComments": {
            "type": Number,
            "required": true
        },
        "createdAt": {
            "type": Date,
            "required": false
        },
        "startTime": {
            "type": Date,
            "required": true
        },
        "endTime": {
            "type": Date,
            "required": false
        },
        "repetition": {
            "type": String,
            "required": false
        }
    });

module.exports = mongoose.model("future_events", FutureSchema);
