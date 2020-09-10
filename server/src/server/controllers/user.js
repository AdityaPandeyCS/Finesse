const { body, validationResult } = require("express-validator");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const nodemailer = require("nodemailer");

const User = require("../model/user");
const PasswordReset = require("../model/passwordReset");

exports.signup = [
  // Validate fields
  body("emailId", "Please enter a valid emailId").isEmail().trim(),
  body("password", "Please enter a valid password").isLength({ min: 6 }).trim(),

  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      console.log("Error Happened");
      return res.status(400).json({
        errors: errors.array(),
      });
    }

    const { emailId, password } = req.body;
    const atSplit = emailId.split("@");
    const userName = atSplit[0];
    const dotSplit = atSplit[1].split(".");
    const school = dotSplit[0];
    const points = 0;
    const notifications = true;
    const upvoted = [];
    const downvoted = [];
    const subscriptions = [];

    let user = await User.findOne({ emailId });
    if (user) {
      return res.status(400).json({
        msg: "User already exists",
      });
    }

    user = new User({
      userName,
      emailId,
      password,
      school,
      points,
      notifications,
      upvoted,
      downvoted,
      subscriptions,
    });

    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(password, salt);

    await user.save();

    const payload = {
      user: {
        id: user.id,
      },
    };

    jwt.sign(
      payload,
      "randomString",
      {
        expiresIn: 10000,
      },
      (err, token) => {
        if (err) throw err;
        res.status(200).json({
          token,
        });
      }
    );
  },
];

exports.login = [
  // Validate fields
  body("emailId", "Please enter a valid emailId").isEmail().trim(),
  body("password", "Please enter a valid password").isLength({ min: 6 }).trim(),

  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        errors: errors.array(),
      });
    }

    const { emailId, password } = req.body;

    let user = await User.findOne({ emailId });
    if (!user) {
      return res.status(400).json({
        message: "User does not exist",
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({
        message: "Incorrect Password !",
      });
    }

    const payload = {
      user: {
        id: user.id,
      },
    };

    jwt.sign(
      payload,
      "randomString",
      {
        expiresIn: 3600,
      },
      (err, token) => {
        if (err) throw err;
        res.status(200).json({
          token,
        });
      }
    );
  },
];

exports.getCurrentUser = [
  // Validate fields
  body("emailId", "Please enter a valid emailId").isEmail().trim(),

  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        errors: errors.array(),
      });
    }

    const { emailId } = req.body;

    let user = await User.findOne({ emailId });
    if (!user) {
      return res.status(400).json({
        message: "User does not exist",
      });
    }

    res.status(200).json(user);
  },
];

exports.setVotes = [
  // Validate fields
  body("emailId", "Please enter a valid emailId").isEmail().trim(),

  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        errors: errors.array(),
      });
    }

    const { emailId, upvoted, downvoted } = req.body;

    try {
      console.log("trying to find " + emailId);
      let user = await User.findOne({ emailId: emailId });
      user.upvoted = upvoted;
      user.downvoted = downvoted;

      await user.save(function (err) {
        if (err) {
          console.log("error saving user = " + err);
          return next(err);
        }
        let logMessage = "Success: set votes for user = " + emailId;
        console.log(logMessage);
        res.status(200).json({
          message: logMessage,
        });
      });
    } catch (err) {
      console.log("Error: unable to set votes: " + err);
      res.status(400).end();
    }
  },
];

exports.getLeaderboard = function (req, res) {
  let currentEmail = req.query.currentEmail;
  User.find({})
    .sort({ points: -1 })
    .exec(function (err, leaderboard) {
      if (err) {
        console.log(err);
        res.status(400).end();
      } else {
        let currentRank = null;
        if (currentEmail) {
          currentRank =
              leaderboard.findIndex((user) => user.emailId === currentEmail) + 1;
        }
        leaderboard = leaderboard.slice(0, 10).filter((user) => user.points >= 0);
        res.json([currentRank, leaderboard]);
      }
    });
};

exports.changeNotifications = [
  // Validate fields
  body("emailId", "Please enter a valid emailId").isEmail().trim(),

  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        errors: errors.array(),
      });
    }

    const { emailId, notifications } = req.body;

    try {
      let user = await User.findOne({ emailId: emailId });
      user.notifications = notifications;
      await user.save(function (err) {
        if (err) {
          return next(err);
        }
        let logMessage = "Success: updated notifications for user = " + emailId;
        console.log(logMessage);
        res.status(200).json({
          message: logMessage,
        });
      });
    } catch (err) {
      console.log(
        "Error: unable to find user " + emailId + " to update notifications"
      );
      res.status(400).end();
    }
  },
];

exports.deleteUser = [
  async (req, res) => {
    const { emailId } = req.body;

    let user = await User.findOne({ emailId });
    if (!user) {
      return res.status(400).json({
        message: "User does not exist",
      });
    }

    await user.remove();

    res.status(200).json({
      message: "User (" + emailId + ") deleted.",
    });
  },
];

exports.checkEmailExists = [
  // Validate fields
  body("emailId", "Please enter a valid emailId").isEmail().trim(),

  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        errors: errors.array(),
      });
    }

    const { emailId } = req.body;

    let user = await User.findOne({ emailId });
    if (!user) {
      return res.status(400).json({
        message: "User does not exist",
      });
    }

    res.status(200).json({
      msg: "User found",
    });
  },
];

exports.generatePasswordResetLink = [
  // Validate fields
  body("emailId", "Please enter a valid emailId").isEmail().trim(),

  async (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        errors: errors.array(),
      });
    }

    const { emailId } = req.body;

    // Check if user already sent password reset request and refresh new token if exists
    let user = await PasswordReset.findOne({ emailId });
    if (user) {
      await user.remove();
    }

    // Add password reset token to db
    let token = crypto.randomBytes(32).toString("hex");
    let creationTime = Date.now();
    let passwordReset = new PasswordReset({
      emailId,
      token,
      creationTime,
    });

    await passwordReset.save();

    // Send password reset link to users email
    let transport = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.EMAIL_USERNAME,
        pass: process.env.EMAIL_PASSWORD,
      },
    });

    const message = {
      from: "xXFinesseNationXx@gmail.com",
      to: emailId,
      subject: "Finesse Nation - Password Reset",
      html:
        '<p>Click <a href="https://finesse-nation.herokuapp.com/admin/users?email=' +
        emailId +
        "&token=" +
        token +
        '">here</a> to reset your password</p>',
    };

    transport.sendMail(message, function (err) {
      if (err) {
        console.log(err);
        return next(err);
      }
      res.status(200).json({
        msg: "Password reset token sent to user email",
        token: token,
      });
    });
  },
];
