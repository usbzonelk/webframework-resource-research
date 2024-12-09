const dbConfig = require("./config/db");
const serverConfig = require("./config/index");
const express = require("express");
const app = express();

const PORT = serverConfig.serverPort;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(dbConfig.dbCheckMiddleware);

dbConfig.connectToDatabase();

app.listen(PORT, () => {
  console.log(`App running on: ${PORT}`);
});
