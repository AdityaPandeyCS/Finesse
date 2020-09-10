let server = require("../src/server/index");
let chai = require("chai");
let chaiHttp = require("chai-http");
let expect = chai.expect;

chai.use(chaiHttp);

describe("comments", () => {
    it("it should create a comment for an event", (done) => {
        let comment = {
            "eventId": "5ece1abf1b3bbf0017bd5e3a",
            "emailId": "test",
            "comment": "TEST Amazing Event",
            "postedTime": "2020-04-01 03:29:03.693069"
        };
        test_server_response("/api/comment", 200, comment);
        done();
    });

    it("it checks for errors while creating a comment for an event", (done) => {
        let comment = {
            "eventI": "5ece1abf1b3bbf0017bd5e3a",
            "emailI": "test",
            "commen": "TEST Amazing Event",
            "postedTime": "2020-04-01 03:29:03.693069"
        };
        test_server_response("/api/comment", 400, comment);
        done();
    });

    function test_server_response(serverUrl, statusCode, comment) {
        chai.request(server)
            .post(serverUrl)
            .set("api_token", process.env.API_TOKEN)
            .send(comment)
            .end((err, res) => {
                expect(res).to.have.status(statusCode);
                // expect(res.text).to.equal("Success: added new comment = Mocha Test Comment");
                // done();
            });
    }

    it("it should return list of comment associated with an event", (done) => {
        chai.request(server)
            .get("/api/comment/targetEventId")
            .set("api_token", process.env.API_TOKEN)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res).to.be.json;
            });
        done();
    });
});
