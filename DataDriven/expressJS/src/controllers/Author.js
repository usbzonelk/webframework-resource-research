const Author = require("../models/Author");
const Post = require("../models/Post");

exports.getPosts = async (req, res) => {
  try {
    const { emails } = req.body;
    const authors = await Author.find({ email: { $in: emails } }).exec();
    if (authors.length < 1) {
      return res.status(200).json({ result: "No authors found." });
    }
    const authorIDs = authors.map(({ _id }) => _id);
    const postsByAuthor = await Post.find({
      authors: { $in: authorIDs },
    }).exec();
    if (postsByAuthor.length < 1) {
      res.status(200).json({ result: "No posts found." });
    } else {
      res.status(200).json({ result: postsByAuthor });
    }
  } catch (e) {
    res.status(500).json({ error: `${e}` });
  }
};
