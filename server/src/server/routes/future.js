const express = require("express");
const router = express.Router();

const futureController = require('../controllers/future');

router.get('/', futureController.getEvents);

router.post('/', futureController.addEvent);

router.put('/:eventId', futureController.updateEvent);

router.delete('/:eventId', futureController.deleteEvent);

module.exports = router;