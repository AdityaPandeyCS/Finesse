const mongoose = require("mongoose");

const MONGOURI = "mongodb+srv://" + process.env.MONGODB_USERNAME + ":" + process.env.MONGODB_PASSWORD + "@cluster0-xwfi7.mongodb.net/free_food?retryWrites=true&w=majority";

/**
 * Establish mongodb connection and make it available to app.
 * @returns {Promise<void>}
 * @constructor
 */
const InitiateMongoServer = async () => {
    try {
        await mongoose.connect(MONGOURI, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
            useFindAndModify: false
        });
        console.log("Connected to DB !!");
    } catch (e) {
        console.log(e);
        throw e;
    }
};

module.exports = { InitiateMongoServer, MONGOURI };