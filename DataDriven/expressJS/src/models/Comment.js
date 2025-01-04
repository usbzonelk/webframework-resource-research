const mongoose = require("mongoose");
const Post = require("./Post");
const Counter = require("./Counter");

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
commentSchema.pre("save", async function (next) {
  if (this.isNew) {
    try {
      const counter = await Counter.findOneAndUpdate(
        { name: "commentId" },
        { $inc: { value: 1 } },
        { new: true, upsert: true }
      );

      this.id = counter.value;
      next();
    } catch (err) {
      next(err);
    }
  } else {
    next();
  }
});
module.exports = mongoose.model("Comment", commentSchema);
