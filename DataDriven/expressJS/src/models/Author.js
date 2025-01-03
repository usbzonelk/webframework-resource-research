const mongoose = require("mongoose");
const Counter = require("./Counter");

const authorSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    maxlength: 150,
  },
  email: {
    type: String,
    required: true,
    unique: true,
    index: true,
  },
  id: {
    type: Number,
    required: true,
    unique: true,
    index: true,
  },
});
authorSchema.plugin(require("mongoose-autopopulate"));
authorSchema.pre("save", async function (next) {
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
module.exports = mongoose.model("Author", authorSchema);
