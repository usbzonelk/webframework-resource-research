const express = require("express");
const router = express.Router();
const Comment = require("../controllers/Comment");

router.post("/create-bulk", Comment.createBulk);
router.post("/delete-bulk", Comment.deleteBulk);

module.exports = router;
