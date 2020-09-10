const mongoose = require("mongoose"),

    VoteSchema = mongoose.Schema({
        "eventId": {
            "type": String,
            required: 'Please enter correct event id.',
            trim: true
        },
        "emailId": {
            "type": String,
            required: 'Please enter the email id',
            trim: true
        },
        "vote": {
            "type": Number,
            "required": true
        }
    });

// Export model comment with CommentSchema
module.exports = mongoose.model("finesse_nation_votes", VoteSchema);


