const mongoose = require("mongoose");
const Post = require("./Post");

const commentSchema = new mongoose.Schema({
  authorName: {
    type: String,
    default: "",
    required: true,
    maxlength: 50,
  },
  id: {
    type: Number,
    required: true,
    index: true,
    unique: true,
  },
  content: {
    type: String,
    required: true,
  },
  lastUpdated: {
    type: Date,
    default: new Date(),
  },
  post: {
    type: mongoose.Schema.ObjectId,
    ref: "Post",
    required: true,
    autopopulate: true,
  },
});
commentSchema.plugin(require("mongoose-autopopulate"));
module.exports = mongoose.model("Comment", commentSchema);