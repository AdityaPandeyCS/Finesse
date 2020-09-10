let server = require("../src/server/index");
let chai = require("chai");
let chaiHttp = require("chai-http");
let expect = chai.expect;

chai.use(chaiHttp);

describe("login", () => {
    // -------------------- Test cases --------------------

    let passwordResetToken = "";
    let userId = "";

    it("it should signup a new user", (done) => {
        let newUser = {
            "emailId": "testmocha1@mochauniversity.edu",
            "password": "testmocha1pass"
        };
        chai.request(server)
            .post("/api/user/signup")
            .set("api_token", process.env.API_TOKEN)
            .send(newUser)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body.token).to.be.a("string");
                expect(res).to.be.json;
                done();
            });
    });

    it("it should fail signup for already registered user", (done) => {
        let newUser = {
            "emailId": "testmocha1@mochauniversity.edu",
            "password": "testmocha1pass"
        };
        chai.request(server)
            .post("/api/user/signup")
            .set("api_token", process.env.API_TOKEN)
            .send(newUser)
            .end((err, res) => {
                expect(res).to.have.status(400);
                done();
            });
    });

    it("it should fail user signup for incorrect email", (done) => {
        let newUser = {
            "emailId": "testmocha1_mochauniversity.edu",
            "password": "testmocha1pass"
        };
        chai.request(server)
            .post("/api/user/signup")
            .set("api_token", process.env.API_TOKEN)
            .send(newUser)
            .end((err, res) => {
                expect(res).to.have.status(400);
                done();
            });
    });

    it("it should login as user with correct password", (done) => {
        let loginCreds = {
            "emailId": "testmocha1@mochauniversity.edu",
            "password": "testmocha1pass"
        };
        chai.request(server)
            .post("/api/user/login")
            .set("api_token", process.env.API_TOKEN)
            .send(loginCreds)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body.token).to.be.a("string");
                expect(res.body.token).to.be.length.greaterThan(0);
                done();
            });
    });

    it("it should throw error on login for invalid email", (done) => {
        let loginCreds = {
            "emailId": "testmocha1_mochauniversity.edu",
            "password": "testmocha1pass"
        };
        chai.request(server)
            .post("/api/user/login")
            .set("api_token", process.env.API_TOKEN)
            .send(loginCreds)
            .end((err, res) => {
                expect(res).to.have.status(400);
                done();
            });
    });

    it("it should get current user information", (done) => {
        let email = {
            "emailId": "testmocha1@mochauniversity.edu"
        };
        chai.request(server)
            .post("/api/user/getCurrentUser")
            .set("api_token", process.env.API_TOKEN)
            .send(email)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res).to.be.json;
                expect(res.body.emailId === "testmocha1@mochauniversity.edu");
                expect(res.body.notifications ===  true );

                done();
            });
    });

    it("it should throw error on get current user for invalid email", (done) => {
        let email = {
            "emailId": "testmocha1_mochauniversity.edu"
        };
        chai.request(server)
            .post("/api/user/getCurrentUser")
            .set("api_token", process.env.API_TOKEN)
            .send(email)
            .end((err, res) => {
                expect(res).to.have.status(400);
                done();
            });
    });

    it("it should not find existing user", (done) => {
        let email = {
            "emailId": "testmocha2@mochauniversity.edu"
        };
        chai.request(server)
            .post("/api/user/getCurrentUser")
            .set("api_token", process.env.API_TOKEN)
            .send(email)
            .end((err, res) => {
                expect(res).to.have.status(400);
                expect(res.body.message).to.equal("User does not exist");
                done();
            });
    });


    it("it should find existing user", (done) => {
        let email = {
            "emailId": "testmocha1@mochauniversity.edu"
        };
        chai.request(server)
            .post("/api/user/checkEmailExists")
            .set("api_token", process.env.API_TOKEN)
            .send(email)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body.msg).to.equal("User found");
                done();
            });
    });

    it("it should throw error on find existing user for invalid email", (done) => {
        let email = {
            "emailId": "testmocha1_mochauniversity.edu"
        };
        chai.request(server)
            .post("/api/user/checkEmailExists")
            .set("api_token", process.env.API_TOKEN)
            .send(email)
            .end((err, res) => {
                expect(res).to.have.status(400);
                done();
            });
    });

    it("it should not find existing user", (done) => {
        let email = {
            "emailId": "testmocha2@mochauniversity.edu"
        };
        chai.request(server)
            .post("/api/user/checkEmailExists")
            .set("api_token", process.env.API_TOKEN)
            .send(email)
            .end((err, res) => {
                expect(res).to.have.status(400);
                expect(res.body.message).to.equal("User does not exist");
                done();
            });
    });

    it("it should not login as user with incorrect password", (done) => {
        let loginCreds = {
            "emailId": "testmocha1@mochauniversity.edu",
            "password": "testmocha2pass"
        };
        chai.request(server)
            .post("/api/user/login")
            .set("api_token", process.env.API_TOKEN)
            .send(loginCreds)
            .end((err, res) => {
                expect(res).to.have.status(400);
                expect(res.body.message).to.equal("Incorrect Password !");
                expect(res).to.be.json;
                done();
            });
    });

    it("it should not login as user with non-existent username", (done) => {
        let loginCreds = {
            "emailId": "testmochafake@mochauniversity.edu",
            "password": "testmochafakepass"
        };
        chai.request(server)
            .post("/api/user/login")
            .set("api_token", process.env.API_TOKEN)
            .send(loginCreds)
            .end((err, res) => {
                expect(res).to.have.status(400);
                expect(res.body.message).to.equal("User does not exist");
                expect(res).to.be.json;
                done();
            });
    });

    it("it should not login as no api_key is passed", (done) => {
        let loginCreds = {
            "emailId": "testmocha1@mochauniversity.edu",
            "password": "testmocha1pass"
        };
        chai.request(server)
            .post("/api/user/login")
            .send(loginCreds)
            .end((err, res) => {
                expect(res).to.have.status(401);
                expect(res.body.message).to.equal("Request is not authorized.");
                expect(res).to.be.json;
                done();
            });
    });

    it("it should generate email link for password reset", (done) => {
        let loginCreds = {
            "emailId": "testmocha1@mochauniversity.edu"
        };
        chai.request(server)
            .post("/api/user/generatePasswordResetLink")
            .set("api_token", process.env.API_TOKEN)
            .send(loginCreds)
            .end((err, res) => {
                passwordResetToken = res.body.token;
                expect(res).to.have.status(200);
                expect(res.body.msg).to.equal("Password reset token sent to user email");
                done();
            });
    });

    it("it should check token is valid for password reset request", (done) => {
        let emailToken = {
            "emailId": "testmocha1@mochauniversity.edu",
            "token": passwordResetToken
        };
        chai.request(server)
            .post("/admin/api/user/checkEmailTokenExists")
            .send(emailToken)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body.msg).to.equal("Found valid email/token");
                expect(res.body.userId).length.gte(24);
                userId = res.body.userId;
                done();
            });
    });

    it("it should generate email link for password reset for existing user", (done) => {
        let loginCreds = {
            "emailId": "testmocha1@mochauniversity.edu"
        };
        chai.request(server)
            .post("/api/user/generatePasswordResetLink")
            .set("api_token", process.env.API_TOKEN)
            .send(loginCreds)
            .end((err, res) => {
                passwordResetToken = res.body.token;
                expect(res).to.have.status(200);
                expect(res.body.msg).to.equal("Password reset token sent to user email");
                done();
            });
    });

    it("it should throw error on generate email link password reset for invalid email", (done) => {
        let loginCreds = {
            "emailId": "testmocha0_mochauniversity.edu"
        };
        chai.request(server)
            .post("/api/user/generatePasswordResetLink")
            .set("api_token", process.env.API_TOKEN)
            .send(loginCreds)
            .end((err, res) => {
                passwordResetToken = res.body.token;
                expect(res).to.have.status(400);
                done();
            });
    });

    it("it should fail check token exists for invalid email", (done) => {
        let emailToken = {
            "emailId": "testmocha1_mochauniversity.edu",
            "token": passwordResetToken
        };
        chai.request(server)
            .post("/admin/api/user/checkEmailTokenExists")
            .send(emailToken)
            .end((err, res) => {
                expect(res).to.have.status(400);
                done();
            });
    });

    it("it should throw error on check email token exists for incorrect token", (done) => {
        let emailToken = {
            "emailId": "testmochaz@mochauniversity.edu",
            "token": "acc0f1fe898cdf038777a1a3056b73d021d9196229b6287e8c79cb8ae3451dde"
        };
        chai.request(server)
            .post("/admin/api/user/checkEmailTokenExists")
            .send(emailToken)
            .end((err, res) => {
                expect(res).to.have.status(401);
                done();
            });
    });

    it("it should send successful request for notification change", (done) => {
        let emailId = "testmocha1@mochauniversity.edu";
        let notificationUpdate = {
            "emailId": emailId,
            "notifications": false
        };
        chai.request(server)
            .post("/api/user/changeNotifications")
            .set("api_token", process.env.API_TOKEN)
            .send(notificationUpdate)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body.message).to.equal("Success: updated notifications for user = " + emailId);
                done();
            });
    });

    it("it should throw error on notification change for invalid email", (done) => {
        let notificationUpdate = {
            "emailId": "testmocha1_mochauniversity.edu",
            "notifications": false
        };
        chai.request(server)
            .post("/api/user/changeNotifications")
            .set("api_token", process.env.API_TOKEN)
            .send(notificationUpdate)
            .end((err, res) => {
                expect(res).to.have.status(400);
                done();
            });
    });

    it("it should throw error on notification change for non-existing email", (done) => {
        let notificationUpdate = {
            "emailId": "testmochax@mochauniversity.edu",
            "notifications": false
        };
        chai.request(server)
            .post("/api/user/changeNotifications")
            .set("api_token", process.env.API_TOKEN)
            .send(notificationUpdate)
            .end((err, res) => {
                expect(res).to.have.status(400);
                done();
            });
    });

    it("it should send successful request for password change", (done) => {
        let emailId = "testmocha1@mochauniversity.edu";
        let loginCreds = {
            "userId": userId,
            "password": "testmocha2pass"
        };
        chai.request(server)
            .post("/admin/api/user/changePassword")
            .send(loginCreds)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body.message).to.equal("Success: updated password for userId = " + userId);
                done();
            });
    });

    it("it should throw error on password change for invalid userid", (done) => {
        let loginCreds = {
            "userId": "12345",
            "password": "testmocha2pass"
        };
        chai.request(server)
            .post("/admin/api/user/changePassword")
            .send(loginCreds)
            .end((err, res) => {
                expect(res).to.have.status(400);
                done();
            });
    });

    it("it should throw error on password change for invalid userid with correct length", (done) => {
        let loginCreds = {
            "userId": "5e90ddf926775a6df5c90a1z",
            "password": "testmocha2pass"
        };
        chai.request(server)
            .post("/admin/api/user/changePassword")
            .send(loginCreds)
            .end((err, res) => {
                expect(res).to.have.status(400);
                done();
            });
    });

    it("it should assert users password was changed", (done) => {
        let loginCreds = {
            "emailId": "testmocha1@mochauniversity.edu",
            "password": "testmocha2pass"
        };
        chai.request(server)
            .post("/api/user/login")
            .set("api_token", process.env.API_TOKEN)
            .send(loginCreds)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body.token).to.be.a("string");
                expect(res.body.token).to.be.length.greaterThan(0);
                done();
            });
    });

    it("it should not delete for user that does not exist", (done) => {
        let emailId = {
            "emailId": "testmocha0@mochauniversity.edu"
        };
        chai.request(server)
            .post("/api/user/deleteUser")
            .set("api_token", process.env.API_TOKEN)
            .send(emailId)
            .end((err, res) => {
                expect(res).to.have.status(400);
                expect(res.body.message).to.equal("User does not exist");
                expect(res).to.be.json;
                done();
            });
    });

    // -------------------- After tests --------------------

    it("it should delete user for cleanup", (done) => {
        let emailId = {
            "emailId": "testmocha1@mochauniversity.edu"
        };
        chai.request(server)
            .post("/api/user/deleteUser")
            .set("api_token", process.env.API_TOKEN)
            .send(emailId)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body.message).to.equal("User (testmocha1@mochauniversity.edu) deleted.");
                expect(res).to.be.json;
                done();
            });
    });
});
