const express = require("express");
const router = express.Router();

const eventController = require('../controllers/event');

router.get('/getEvents', eventController.getEvents);

router.get('/getEvents/:eventId', eventController.getEvent);

router.post('/addEvent', eventController.addEvent);

router.post('/updateEvent', eventController.updateEvent);

router.post('/deleteEvent', eventController.deleteEvent);

module.exports = router;
