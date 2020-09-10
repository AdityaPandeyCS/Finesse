const Subscription = require("../model/subscription");

exports.addSubscription = async (req, res, next) => {
    const {email} = req.body;
    let subscriptionjson = {
        email: email
    };
    let subscription = new Subscription(subscriptionjson);
    await subscription.save(function (err, _) {
        if (err) {
            console.log(err);
            return next(err);
        }
        res.send('Successfully added subscription');
    });
};
