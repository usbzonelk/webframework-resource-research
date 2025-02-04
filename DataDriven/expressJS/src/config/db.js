const mongoose = require("mongoose");

async function connectToDatabase() {
  try {
    await mongoose.connect(`mongodb://admin:adminpassword@127.0.0.1:61012/datadriven?directConnection=true&serverSelectionTimeoutMS=2000&authSource=admin&retryWrites=true&w=majority&appName=mongosh+2.3.8`);
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
