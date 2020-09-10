const swaggerJsdoc = require('swagger-jsdoc');

const options = {
    // List of files to be processes. You can also set globs './routes/*.js'
    apis: ['./src/server/routes/*.js'],
    basePath: '/',
    swaggerDefinition: {
        // Like the one described here: https://swagger.io/specification/#infoObject
        info: {
            title: 'Finesse-Nation-Backend',
            swagger: '2.0',
            description: 'Backend service for the free food app.',
            version: '1.0.0',
        },
    },
};

const specs = swaggerJsdoc(options);
module.exports = specs;
