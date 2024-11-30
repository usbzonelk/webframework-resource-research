const mongoose = require("mongoose");

const categorySchema = new mongoose.Schema({
  name: {
    type: String,
    maxlength: 150,
    required: true,
  },
});
module.exports = mongoose.model("Category", categorySchema);
