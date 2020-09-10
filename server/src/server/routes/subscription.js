const express = require('express'),
    router = express.Router();

const subscriptionController = require('../controllers/subscription');

router.post('/', subscriptionController.addSubscription);

module.exports = router;
