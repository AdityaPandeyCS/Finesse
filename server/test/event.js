let server = require("../src/server/index");
let chai = require("chai");
let chaiHttp = require("chai-http");
let expect = chai.expect;

chai.use(chaiHttp);

describe("events", () => {
    // -------------------- Before tests --------------------

    let targetEventId = "";

    it("it should create an event", (done) => {
        let event = {
            "eventTitle": "Mocha Test Event",
            "emailId": "darko123@gmail.com",
            "school": "UIUC",
            "description": "Mocha test event description.",
            "location": "Mocha location",
            "isActive": [],
            "duration": "2 hrs",
            "postedTime": "2020-04-01 03:29:03.693069",
            "image": "",
            "category": "Food",
            "points": 1,
            "numComments": 0
        };
        chai.request(server)
            .post("/api/food/addEvent")
            .set("api_token", process.env.API_TOKEN)
            .send(event)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body.msg).to.equal("Success: added new event = Mocha Test Event");
                done();
            });
    });

    // -------------------- Test cases --------------------

    it("it should return list of events", (done) => {
        chai.request(server)
            .get("/api/food/getEvents")
            .set("api_token", process.env.API_TOKEN)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res).to.be.json;
                done();
            });
    });

    it("it should throw error on event add for empty eventTitle", (done) => {
        let event = {
            "eventTitle": "",
            "emailId": "darko123@gmail.com",
            "school": "UIUC",
            "description": "Mocha test event description.",
            "location": "Mocha location",
            "isActive": [],
            "duration": "2 hrs",
            "postedTime": "2020-04-01 03:29:03.693069",
            "image": "",
            "category": "Food",
            "points": 1,
            "numComments": 0
        };
        chai.request(server)
            .post("/api/food/addEvent")
            .set("api_token", process.env.API_TOKEN)
            .send(event)
            .end((err, res) => {
                expect(res).to.have.status(400);
                done();
            });
    });

    it("it should return _id of created event", (done) => {
        chai.request(server)
            .get("/api/food/getEvents")
            .set("api_token", process.env.API_TOKEN)
            .end((err, res) => {
                for (let i = 0; i < res.body.length; i++) {
                    if (res.body[i].eventTitle === "Mocha Test Event" && res.body[i].description === "Mocha test event description.") {
                        targetEventId = res.body[i]._id;
                        break;
                    }
                }
                expect(res).to.have.status(200);
                expect(res).to.be.json;
                expect(targetEventId).to.be.length.greaterThan(0);
                done();
            });
    });

    it("it should update created event", (done) => {
        let eventUpdate = {
            "eventId": targetEventId.toString(),
            "eventTitle": "Mocha Test Event",
            "emailId": "darko123@gmail.com",
            "school": "UIUC",
            "description": "Mocha test event description.",
            "location": "Mocha location",
            "isActive": [],
            "duration": "2 hrs",
            "postedTime": "2020-04-01 03:29:03.693069",
            "image": "",
            "category": "Food",
            "points": 1,
            "numComments": 0
        };
        chai.request(server)
            .post("/api/food/updateEvent")
            .set("api_token", process.env.API_TOKEN)
            .send(eventUpdate)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.text).to.equal("Success: updated event _id = " + targetEventId);
                done();
            });
    });

    it("it should throw error on event add for empty eventTitle", (done) => {
        let eventUpdate = {
            "eventId": targetEventId.toString(),
            "eventTitle": "",
            "emailId": "darko123@gmail.com",
            "school": "UIUC",
            "description": "Mocha test event description.",
            "location": "Mocha location",
            "isActive": [],
            "duration": "2 hrs",
            "postedTime": "2020-04-01 03:29:03.693069",
            "image": "",
            "category": "Food",
            "points": 1,
            "numComments": 0
        };
        chai.request(server)
            .post("/api/food/updateEvent")
            .set("api_token", process.env.API_TOKEN)
            .send(eventUpdate)
            .end((err, res) => {
                expect(res).to.have.status(400);
                done();
            });
    });

    it("it should not update created event due to no api_key", (done) => {
        let eventUpdate = {
            "eventId": targetEventId,
            "name": "Mocha Test Event 2",
            "description": "Mocha Crawfish broil",
            "location": "Mocha location",
            "duration": "3 hrs",
            "timePosted": "2020-04-01 03:29:03.6930690"
        };
        chai.request(server)
            .post("/api/food/updateEvent")
            .send(eventUpdate)
            .end((err, res) => {
                expect(res).to.have.status(401);
                done();
            });
    });

    it("it should not update created event due to no non-existing eventId", (done) => {
        let eventUpdate = {
            "eventId": "5e9537316f5e40002ecc9a3z",
            "eventTitle": "Josol Test Event",
            "emailId": "mocha@mochatest.com",
            "school": "UIUC",
            "description": "Mocha test event description.",
            "location": "Mocha location",
            "isActive": [],
            "duration": "2 hrs",
            "postedTime": "2020-04-01 03:29:03.693069",
            "image": "",
            "category": "Food",
            "points": 1,
            "numComments": 0
        };
        chai.request(server)
            .post("/api/food/updateEvent")
            .set("api_token", process.env.API_TOKEN)
            .send(eventUpdate)
            .end((err, res) => {
                expect(res).to.have.status(400);
                done();
            });
    });

    // -------------------- After tests --------------------

    it("it should delete created event", (done) => {
        let eventDelete = {
            "eventId": targetEventId
        };
        chai.request(server)
            .post("/api/food/deleteEvent")
            .set("api_token", process.env.API_TOKEN)
            .send(eventDelete)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.text).to.equal("Success: deleted event _id = " + targetEventId);
                done();
            });
    });
});
