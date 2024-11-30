const mongoose = require("mongoose");

const postSchema = new mongoose.Schema({
  title: {
    type: String,
    default: "",
    required: true,
    maxlength: 200,
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
module.exports = mongoose.model("Post", postSchema);
