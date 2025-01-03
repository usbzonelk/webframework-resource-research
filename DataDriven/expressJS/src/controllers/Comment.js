const Comment = require("../models/Comment");
const Post = require("../models/Post");

exports.createBulk = async (req, res) => {
  const commentsData = Object.assign([], req.body.commentsData);
  if (!Array.isArray(commentsData.commentsData) && commentsData.length < 1) {
    return res.status(422).json({ error: "Invalid request data." });
  }
  try {
    const commentSavingAsync = commentsData.map(async (commentInput) => {
      const post = await Post.findOne({
        id: commentInput.post,
      }).exec();
      if (!post) throw new Error("Post not found! " + commentInput.post);
      commentInput.post = post._id;
      commentInput.id = 5;
      const savedComment = await Comment.create(commentInput);
      if (!savedComment) {
        throw new Error("Error creating database entry!");
      }
    });
    Promise.all(commentSavingAsync)
      .then(() => {
        res.status(200).json({ success: true });
      })
      .catch((e) => {
        res.status(500).json({ error: `${e}` });
      });
  } catch (e) {
    res.status(500).json({ error: `${e}` });
  }
};

exports.deleteBulk = async (req, res) => {
  const { postIDs } = req.body;
  if (!Array.isArray(postIDs) || postIDs.length < 1) {
    return res.status(422).json({ error: "Invalid request data." });
  }
  try {
    const posts = await Post.find({ id: { $in: postIDs } }).exec();
    if (posts.length < 1) {
      return res.status(200).json({ result: "No ppsts found." });
    }
    const postMongoIDs = posts.map(({ _id }) => _id);
    const deleted = await Comment.deleteMany({ post: { $in: postMongoIDs } });
    if (Object.hasOwn(deleted, "acknowledged") && deleted.acknowledged) {
      res.status(200).json({ success: true });
    } else {
      throw new Error("Error deleting database entry!");
    }
  } catch (e) {
    res.status(500).json({ error: `${e}` });
  }
};
