const express = require('express'),
    router = express.Router();

const commentController = require('../controllers/comment');

/**
 * @swagger
 * /api/comment/{eventId}:
 *    get:
 *      tags:
 *          - Comments
 *      summary: Get list of comments for an event.
 *      parameters:
 *        - name: eventId
 *          in: path
 *          description: Id of event.
 *      responses:
 *        200:
 *          description: Successfully return list of comments for an event.
 *          schema:
 *            type: array
 *            items:
 *              type: object
 *              properties:
 *                _id:
 *                  type: string
 *                eventId:
 *                  type: string
 *                emailId:
 *                  type: string
 *                comment:
 *                  type: string
 *              example:
 *                _id: "5e83e49e8fae625ca8695e67"
 *                eventId: "5e83d7b01ed1c835cffc0f15"
 *                emailId: "Darko12@gmail.com"
 *                comment: "Hurry up. One last offer."
 *        400:
 *          description: Fails to return list of comments for an event.
 */
router.get('/:eventId', commentController.getComments);

/**
 * @swagger
 * /api/comment:
 *    post:
 *      tags:
 *          - Comments
 *      summary: Add a new comment for an event.
 *      consumes:
 *        - application/json
 *      parameters:
 *        - name: body
 *          in: body
 *          schema:
 *            type: object
 *            properties:
 *              eventId:
 *                type: string
 *              emailId:
 *                type: string
 *              comment:
 *                type: string
 *              postedTime:
 *                type: string
 *      responses:
 *        200:
 *          description: Successfully added comment for an event.
 *          schema:
 *            type: string
 *            example: "Success: added new comment = Is this still available."
 *        400:
 *          description: Error on comment save or input validation failed.
 */
router.post('/', commentController.addComment);

module.exports = router;
