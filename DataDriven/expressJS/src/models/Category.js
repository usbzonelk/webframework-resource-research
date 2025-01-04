const mongoose = require("mongoose");
const Counter = require("./Counter");

const categorySchema = new mongoose.Schema({
  name: {
    type: String,
    maxlength: 150,
    required: true,
  },
  id: {
    type: Number,
    required: true,
    index: true,
    unique: true,
  },
});
categorySchema.pre("save", async function (next) {
  if (this.isNew) {
    try {
      const counter = await Counter.findOneAndUpdate(
        { name: "catId" },
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
module.exports = mongoose.model("Category", categorySchema);
