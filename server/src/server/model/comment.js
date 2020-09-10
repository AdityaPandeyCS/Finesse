const mongoose = require("mongoose"),

    CommentSchema = mongoose.Schema({
        "eventId": {
            "type": String,
            required: 'Please enter correct event id.',
            trim: true
        },
        "emailId": {
            "type": String,
            required: 'Please enter the email id',
            trim: true,
        },
        "comment": {
            "type": String,
            "required": true
        },
        "postedTime": {
            "type": String,
            "required": true
        },
        "createdAt": {
            "type": Date,
            "required": false
        }
    });

// Export model comment with CommentSchema
module.exports = mongoose.model("finesse_nation_comments", CommentSchema);


