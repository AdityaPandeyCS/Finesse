const mongoose = require("mongoose"),

    UserSchema = mongoose.Schema({
        "emailId": {
            "type": String,
            "required": true
        },
        "password": {
            "type": String,
            "required": true
        },
        "school": {
            "type": String,
            "required": false
        },
        "userName": {
            "type": String,
            "required": false
        },
        "points": {
            "type": Number,
            "default": 0
        },
        "notifications": {
            "type": Boolean,
            "default" : true
        },
        "upvoted": {
            "type": Array,
            "default" : []
        },
        "downvoted": {
            "type": Array,
            "default" : []
        },
        "subscriptions": {
            "type": Array,
            "default" : []
        }
    });

// Export model user with UserSchema
// Finesse_Nation_Users => Mongo is Case Sensitive
module.exports = mongoose.model("finesse_nation_users", UserSchema);
