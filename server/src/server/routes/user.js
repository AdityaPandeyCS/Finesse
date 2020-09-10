const express = require("express");
const router = express.Router();

const userController = require("../controllers/user");

/**
 * @swagger
 * /api/user/signup:
 *    post:
 *      tags:
 *          - Users
 *      summary: Sign-up a new user.
 *      consumes:
 *        - application/json
 *      parameters:
 *        - name: body
 *          in: body
 *          schema:
 *            type: object
 *            properties:
 *              emailId:
 *                type: string
 *              password:
 *                type: string
 *      responses:
 *        200:
 *          description: Successfully signed up user and returns valid token.
 *          schema:
 *            type: object
 *            properties:
 *              token:
 *                type: string
 *            example:
 *               token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoiNWViMWQxOGJkMTc2MWYyMzZkNTJjNDQ0In0sImlhdCI6MTU4ODcxMTgxOSwiZXhwIjoxNTg4NzIxODE5fQ.UjDjX8AnSTOAPuQbZlsbEVsdtqliYTHQeEr0OitEAd8"
 *        400:
 *          description: Error on adding new user, user already exists, or input validation failed.
 */
router.post("/signup", userController.signup);

/**
 * @swagger
 * /api/user/login:
 *    post:
 *      tags:
 *          - Users
 *      summary: Login as user.
 *      consumes:
 *        - application/json
 *      parameters:
 *        - name: body
 *          in: body
 *          schema:
 *            type: object
 *            properties:
 *              emailId:
 *                type: string
 *              password:
 *                type: string
 *      responses:
 *        200:
 *          description: Successfully authorize user and returns valid token.
 *          schema:
 *            type: object
 *            properties:
 *              token:
 *                type: string
 *            example:
 *               token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoiNWViMWQxOGJkMTc2MWYyMzZkNTJjNDQ0In0sImlhdCI6MTU4ODcxMTgxOSwiZXhwIjoxNTg4NzIxODE5fQ.UjDjX8AnSTOAPuQbZlsbEVsdtqliYTHQeEr0OitEAd8"
 *        400:
 *          description: Error if user doesn't exist, incorrect password, or input validation failed.
 */
router.post("/login", userController.login);

router.post("/setVotes", userController.setVotes);

router.get("/getLeaderboard", userController.getLeaderboard);

/**
 * @swagger
 * /api/user/changeNotifications:
 *    post:
 *      tags:
 *          - Users
 *      summary: Toggle notification boolean option for a user.
 *      consumes:
 *        - application/json
 *      parameters:
 *        - name: body
 *          in: body
 *          schema:
 *            type: object
 *            properties:
 *              emailId:
 *                type: string
 *              notifications:
 *                type: boolean
 *      responses:
 *        200:
 *          description: Successfully updated notification option for user.
 *          schema:
 *            type: object
 *            properties:
 *              message:
 *                type: string
 *            example:
 *              message: "Success: updated notifications for user = testjosol1@school1.com"
 *        400:
 *          description: Error if user doesn't exist or input validation failed.
 */
router.post("/changeNotifications", userController.changeNotifications);

/**
 * @swagger
 * /api/user/deleteUser:
 *    post:
 *      tags:
 *          - Users
 *      summary: Delete user.
 *      consumes:
 *        - application/json
 *      parameters:
 *        - name: body
 *          in: body
 *          schema:
 *            type: object
 *            properties:
 *              emailId:
 *                type: string
 *      responses:
 *        200:
 *          description: Successfully deleted user.
 *          schema:
 *            type: object
 *            properties:
 *              message:
 *                type: string
 *            example:
 *              message: "User (testjosol1@school2.com) deleted."
 *        400:
 *          description: User doesn't exist.
 */
router.post("/deleteUser", userController.deleteUser);

/**
 * @swagger
 * /api/user/getCurrentUser:
 *    post:
 *      tags:
 *          - Users
 *      summary: Returns existing user.
 *      consumes:
 *        - application/json
 *      parameters:
 *        - name: body
 *          in: body
 *          schema:
 *            type: object
 *            properties:
 *              emailId:
 *                type: string
 *      responses:
 *        200:
 *          description: Successfully found user to return.
 *          schema:
 *            type: object
 *            properties:
 *              points:
 *                type: string
 *              notifications:
 *                type: boolean
 *              _id:
 *                type: string
 *              userName:
 *                type: string
 *              emailId:
 *                type: string
 *              password:
 *                type: string
 *              school:
 *                type: string
 *              __v:
 *                type: integer
 *            example:
 *              points: 0
 *              notifications: false
 *              _id: "5eb89ca3e0738a295ca2ed7x"
 *              userName: "testjosol1"
 *              emailId: "testjosol1@school1.com"
 *              password: "$2a$11$ukNqi4v40zcGvi7gFkf1ru4qLFXzf946fSoaEfI4D8/.xrGPk2W/e"
 *              school: "school1"
 *              "__v": 0
 *        400:
 *          description: User doesn't exist.
 */
router.post("/getCurrentUser", userController.getCurrentUser);

/**
 * @swagger
 * /api/user/checkEmailExists:
 *    post:
 *      tags:
 *          - Users
 *      summary: Check if email is from an existing user.
 *      consumes:
 *        - application/json
 *      parameters:
 *        - name: body
 *          in: body
 *          schema:
 *            type: object
 *            properties:
 *              emailId:
 *                type: string
 *      responses:
 *        200:
 *          description: Successfully found user from email.
 *          schema:
 *            type: object
 *            properties:
 *              msg:
 *                type: string
 *            example:
 *              msg: "User found"
 *        400:
 *          description: User doesn't exist.
 */
router.post("/checkEmailExists", userController.checkEmailExists);

/**
 * @swagger
 * /api/user/generatePasswordResetLink:
 *    post:
 *      tags:
 *          - Users
 *      summary: Generate password reset link for user who requested to reset password.
 *      consumes:
 *        - application/json
 *      parameters:
 *        - name: body
 *          in: body
 *          schema:
 *            type: object
 *            properties:
 *              emailId:
 *                type: string
 *      responses:
 *        200:
 *          description: Successfully sent email to user with password reset link.
 *          schema:
 *            type: object
 *            properties:
 *              msg:
 *                type: string
 *              token:
 *                type: string
 *            example:
 *              msg: "Password reset token sent to user email"
 *              token: "9960fec787576ccc58fd536f10d52c86d3xc9d61a4f40e88d8db2d9de947c7e0"
 *        400:
 *          description: Failed to send email or failed validation check.
 */
router.post(
  "/generatePasswordResetLink",
  userController.generatePasswordResetLink
);

module.exports = router;
