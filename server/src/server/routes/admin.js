const express = require("express");
const router = express.Router();

const adminController = require('../controllers/admin');

/**
 * @swagger
 * /admin/api/user/changePassword:
 *    post:
 *      tags:
 *          - Admin
 *      summary: Change password of an existing user.
 *      consumes:
 *        - application/json
 *      parameters:
 *        - name: body
 *          in: body
 *          schema:
 *            type: object
 *            properties:
 *              userId:
 *                type: string
 *              password:
 *                type: string
 *      responses:
 *        200:
 *          description: Successfully updated password for user.
 *          schema:
 *            type: object
 *            properties:
 *              message:
 *                type: string
 *            example:
 *               message: "Success: updated password for userId = 5ea89ca3d0738a295ca2ed7d"
 *        400:
 *          description: Error on password update or input validation failed.
 */
router.post('/changePassword', adminController.changePassword);

/**
 * @swagger
 * /admin/api/user/checkEmailTokenExists:
 *    post:
 *      tags:
 *          - Admin
 *      summary: Check if email token and email pair is valid for authorization to reset password.
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
 *              token:
 *                type: string
 *      responses:
 *        200:
 *          description: Found a valid email/token combination.
 *          schema:
 *            type: object
 *            properties:
 *              msg:
 *                type: string
 *              userId:
 *                type: string
 *            example:
 *               msg: "Found valid email/token"
 *               userId: "5ea89ca3d0738a295ca2ed7d"
 *        400:
 *          description: Error on password update or input validation failed.
 *        401:
 *          description: Did not find a valid email/token combination or token has expired.
 */
router.post('/checkEmailTokenExists', adminController.checkEmailTokenExists);

module.exports = router;
