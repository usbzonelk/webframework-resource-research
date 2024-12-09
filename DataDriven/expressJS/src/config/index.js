const dotenv = require("dotenv").config();

const serverPort = process.env.SERVERPORT;

module.exports = { serverPort };
