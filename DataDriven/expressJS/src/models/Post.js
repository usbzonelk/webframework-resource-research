const mongoose = require("mongoose");
const Author = require("./Author");
const Category = require("./Category");
const Counter = require("./Counter");

const postSchema = new mongoose.Schema({
  title: {
    type: String,
    default: "",
    required: true,
    maxlength: 200,
  },
  slug: {
    type: String,
    required: true,
    index: true,
    unique: true,
  },
  id: {
    type: Number,
    required: true,
    index: true,
    unique: true,
  },
  content: {
    type: String,
    default: "",
    required: true,
  },
  authors: [
    {
      type: mongoose.Schema.ObjectId,
      ref: "Author",
      required: true,
      autopopulate: true,
    },
  ],
  categories: [
    {
      type: mongoose.Schema.ObjectId,
      ref: "Category",
      required: true,
      autopopulate: true,
    },
  ],
  lastUpdated: {
    type: Date,
    default: new Date(),
  },
  postStatus: {
    type: String,
    enum: ["Published", "Draft"],
    default: "Published",
  },
});
postSchema.plugin(require("mongoose-autopopulate"));
postSchema.pre("save", async function (next) {
  if (this.isNew) {
    try {
      const counter = await Counter.findOneAndUpdate(
        { name: "postId" },
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
module.exports = mongoose.model("Post", postSchema);
