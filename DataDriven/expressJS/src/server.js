const dbConfig = require("./config/db");
const serverConfig = require("./config/index");
const express = require("express");
const app = express();

const PORT = serverConfig.serverPort;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(dbConfig.dbCheckMiddleware);

app.use("/posts", require("./routes/Post"));
app.use("/authors", require("./routes/Author"));
app.use("/comments", require("./routes/Comment"));

dbConfig.connectToDatabase();

app.listen(PORT, () => {
  console.log(`App running on: http://127.0.0.1:${PORT}`);
});
