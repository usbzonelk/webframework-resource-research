const Post = require("../models/Post");
const Comment = require("../models/Comment");

exports.create = async (req, res) => {
  const postData = Object.assign({}, req.body.postData);
  try {
    const postCreation = await Post.create({ ...postData, id: 0 }).then(
      (postDataTemp) => postDataTemp.toObject()
    );
    if (Object.hasOwn(postCreation, "_id") && postCreation._id) {
      res.status(200).json({ success: true });
    } else {
      throw new Error("Error creating database entry!");
    }
  } catch (e) {
    res.status(500).json({ error: `${e}` });
    console.log(e);
  }
};

exports.get = async (req, res) => {
  const page = req.query.page || 1;
  const size = req.query.size || 10;
  try {
    const posts = await Post.find({})
      .populate("authors")
      .populate("categories")
      .skip(size * (page - 1))
      .limit(size)
      .exec();
    if (posts.length < 1) {
      res.status(200).json({ result: "No posts found." });
    } else {
      res.status(200).json({ result: posts });
    }
  } catch (e) {
    res.status(500).json({ error: `${e}` });
  }
};

exports.bulkStatusUpdate = async (req, res) => {
  const { postIDs, newStatus } = req.body;
  if (!newStatus || !Array.isArray(postIDs) || postIDs.length < 1)
    return res.status(422).json({ error: "Invalid request data." });
  try {
    const updated = await Post.updateMany(
      { id: { $in: postIDs } },
      { $set: { postStatus: newStatus } }
    );

    if (Object.hasOwn(updated, "acknowledged") && updated.acknowledged) {
      res.status(200).json({ success: true });
    } else {
      throw new Error("Error updating database entry!");
    }
  } catch (e) {
    res.status(500).json({ error: `${e}` });
    console.log(e);
  }
};

exports.edit = async (req, res) => {
  const postData = Object.assign({}, req.body.postData);
  if (Object.keys(postData).length < 1 || !Object.hasOwn(postData, "id"))
    return res.status(422).json({ error: "Invalid request." });
  try {
    const updated = await Post.findOneAndUpdate({ id: postData.id }, postData, {
      new: true,
    });
    if (updated) {
      res.status(200).json({ success: true });
    } else {
      throw new Error("Error updating database entry!");
    }
  } catch (e) {
    res.status(500).json({ error: `${e}` });
  }
};

exports.search = async (req, res) => {
  try {
    const search = req.query.search;
    if (!search)
      return res.status(422).json({ error: "Invalid request data." });
    const posts = await Post.find({
      $or: [
        { title: { $regex: `.*${search}.*`, $options: "i" } },
        { content: { $regex: `.*${search}.*`, $options: "i" } },
      ],
    });
    if (posts.length < 1) {
      res.status(200).json({ result: "No posts found." });
    } else {
      res.status(200).json({ result: posts });
    }
  } catch (e) {
    res.status(500).json({ error: `${e}` });
  }
};

exports.sortByDate = async (req, res) => {
  try {
    const posts = await Post.find({}).sort({ lastUpdated: "desc" });
    if (posts.length < 1) {
      res.status(200).json({ result: "No posts found." });
    } else {
      res.status(200).json({ result: posts });
    }
  } catch (e) {
    res.status(500).json({ error: `${e}` });
  }
};

exports.popularPosts = async (req, res) => {
  try {
    const maxPosts = await Comment.aggregate([
      {
        $group: {
          _id: "$post",
          count: { $sum: 1 },
        },
      },
      { $sort: { count: -1 } },
      { $limit: 10 },
    ]);
    let postIDs = [];
    if (maxPosts.legnth < 1) {
      res.status(200).json({ result: "No posts found." });
    } else {
      postIDs = maxPosts.map(({ _id }) => _id);
    }
    const posts = await Post.find({ _id: { $in: postIDs } })
      .populate("authors")
      .populate("categories");
    if (posts.length < 1) {
      res.status(200).json({ result: "No posts found." });
    } else {
      res.status(200).json({ result: posts });
    }
  } catch (e) {
    res.status(500).json({ error: `${e}` });
  }
};
