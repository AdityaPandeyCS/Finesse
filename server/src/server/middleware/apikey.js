const apiToken = process.env.API_TOKEN

/**
 * Authenticates certain paths to require api key for security.
 * @param req
 * @param res
 * @param next
 * @returns {*}
 */
module.exports = function(req, res, next) {
    if(req.originalUrl.startsWith('/api')) {
        if(req.headers.api_token !== apiToken) {
            return res.status(401).json({
                message: "Request is not authorized."
            });
        }
    }
    next();
};
