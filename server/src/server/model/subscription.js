const mongoose = require("mongoose"),

    SubscriptionSchema = mongoose.Schema({
        "email": {
            "type": String,
            required: true,
        }
    });

// Export model comment with CommentSchema
module.exports = mongoose.model("mailing_list", SubscriptionSchema);