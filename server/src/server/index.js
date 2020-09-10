require('dotenv').config();

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const specs = require('./swagger');
const { InitiateMongoServer } = require("./config/db");
const apiKeyValidation = require("./middleware/apikey")

InitiateMongoServer();

const app = express();
const eventRoutes = require('./routes/event');
const futureRoutes = require('./routes/future');
const userRoutes = require("./routes/user");
const adminRoutes = require("./routes/admin");
const commentRoutes = require("./routes/comment");
const voteRoutes = require("./routes/vote");
const subscriptionRoutes = require("./routes/subscription");
// const schedulerInAction = require("./controllers/ScheduleCleanUp");

app.use(bodyParser.json({ limit: "16mb", extended: true }));
app.use(bodyParser.urlencoded({ limit: "16mb", extended: true }));
app.use(cors());

// Custom middleware
app.use(apiKeyValidation);

// Routes
// Swagger api docs
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));
// App api routes
app.use('/api/food', eventRoutes);
app.use('/api/future', futureRoutes);
app.use("/api/user", userRoutes);
app.use("/admin/api/user", adminRoutes);
app.use("/api/comment", commentRoutes);
app.use("/api/vote", voteRoutes);
app.use("/subscription", subscriptionRoutes);

app.use(express.static('./src/server/landing'));
app.get('/', function(req, res) {
  res.sendFile('/landing/index.html', {root: './src/server'},function(err) {
    if (err) {
      console.log(err);
      res.status(500).send(err)
    }
  })
});

const PORT = process.env.PORT || 8080;
let server = app.listen(PORT, () => {
  console.log(`Server Started at PORT ${PORT}`);
});

module.exports = server;