const express = require("express");
const app = express();

const PORT = 3001;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.listen(PORT, () => {
  console.log(`App running on: ${PORT}`);
});
