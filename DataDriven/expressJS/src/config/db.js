const dotenv = require("dotenv").config();

const mongoURL = process.env.MONGOURL;
const dbName = process.env.DBNAME;
const mongoServer = process.env.MONGOSERVER || "localhost";

const mongoose = require("mongoose");

async function connectToDatabase() {
  try {
    await mongoose.connect(`mongodb://admin:adminpassword@${mongoServer}:61012/datadriven?authSource=admin&retryWrites=true&w=majority`);
    console.log("Connected to the database");
  } catch (error) {
    console.error("Error connecting to the database:", error.message);
  }
}

function checkDbStatus() {
  if (mongoose.connection.readyState == 1) {
    return { status: true, message: "Connected to database" };
  } else {
    return { status: false, message: "Database connection error" };
  }
}

function dbCheckMiddleware(req, res, next) {
  const dbStatus = checkDbStatus();
  if (!dbStatus.status) {
    res.status(500).send(dbStatus.message);
  } else {
    next();
  }
}

module.exports = { connectToDatabase, checkDbStatus, dbCheckMiddleware };
