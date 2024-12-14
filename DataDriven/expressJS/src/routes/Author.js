const express = require("express");
const router = express.Router();
const Author = require("../controllers/Author");

router.post("/get-posts", Author.getPosts);

module.exports = router;