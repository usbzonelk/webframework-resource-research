const express = require("express");
const router = express.Router();
const Post = require("../controllers/Post");

router.get("/", Post.get);
router.get("/popular", Post.popularPosts);
router.get("/search", Post.search);
router.get("/sort-by-date", Post.sortByDate);
router.post("/create", Post.create);
router.put("/status-update", Post.bulkStatusUpdate);
router.put("/edit", Post.edit);

module.exports = router;
