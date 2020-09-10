const {body, validationResult} = require("express-validator");

const Vote = require("../model/vote");

exports.getVotesByEventId = function(req, res) {
    //event id is accepted as a query param
    let eventId = req.query.eventId;

    Vote.find({"eventId": eventId}).exec(function(err, listVotes) {
        if(err) {  res.status(400).end(); }
        let upVote = 0;
        let downVote = 0;

        for(let i in listVotes){
            if(listVotes[i].vote === 1)
                upVote++;
            else if(listVotes[i].vote === -1) //Condition not required
                downVote++;
        }
        res.json({"upVote": upVote, "downVote":downVote});
    });
};

exports.getPointsForAUser = function(req, res) {
    //event id is accepted as a path param
    let emailId = req.query.emailId;

    Vote.find({"emailId": emailId}).exec(function(err, listVotes) {
        if(err) {  res.status(400).end(); }
        res.json({"points":listVotes.length});
    });
};

exports.getVoteByEventAndUser = function(req, res) {
    let eventId = req.query.eventId;
    let emailId = req.query.emailId;

    Vote.find({"eventId": eventId, "emailId":emailId}).exec(function(err, singleVote) {
        if(err) {  res.status(400).end(); }
        //there will always be a single vote
        let response;
        if(singleVote.length === 0)
            response = "NOT_VOTED";
        else if(singleVote[0].vote === 1)
            response = "UPVOTE";
        else
            response = "DOWNVOTE";
        res.json({"status":response});
    });
};

exports.addVote = [
    // Validate fields
    body("eventId", "Please enter a valid event id").isLength({min: 1}).trim(),
    body("emailId", "Please enter a valid email address").isLength({min: 1}).trim(),
    body("vote", "The user must upvote or downvote").isLength({min: 1}).trim(),

    async (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            console.log("Error Happened");
            return res.status(400).json({
                errors: errors.array()
            });
        }
        const {eventId, emailId, vote} = req.body;

        //vote value must be +1 or -1.
        if(vote !== "1" && vote !== "-1") {
            return res.status(400).json({
                status: "INVALID_VOTE_NUMBER"
            });
        }

        let newVote = new Vote({
            "eventId": eventId,
            "emailId": emailId,
            "vote": vote
        });

        //For simplicity, I am deleting and inserting a vote object
        //To avoid the frontend to make two calls.
        //CONS: Two DB Calls are made now.
        //PROS: Avoids a number of additional checks here, Followed this quick fix approach to fix a BUG! => IMPROVISE.
        let voteElement = await Vote.findOne({"eventId": eventId, "emailId":emailId});
        if (voteElement) {
            Vote.findByIdAndDelete(voteElement._id, function (err) {
                if(err) { return next(err); }
                let logMessage = "Success: deleted vote _id = " + voteElement._id;
                console.log(logMessage);
            });
        }

        await newVote.save(function (err) {
            if (err) {
                res.send({"Error": "adding new vote = " + vote});
                console.log(err);
                //Bad Request
                res.status(400).end();
            } else {
                res.json({"status": "Successfully Upvoted-Downvoted"});
            }
        });
    }
];

exports.deleteVote = [
    async (req, res) => {
        const {eventId, emailId} = req.body;

        let voteElement = await Vote.findOne({"eventId": eventId, "emailId":emailId});
        if (!voteElement) {
            return res.status(400).json({
                message: "Vote does not exist"
            });
        }

        await voteElement.remove();

        let logMessage = "Vote (eventId=" + eventId + ", emailId=" + emailId + ") deleted.";
        res.send(logMessage);
    }
];
