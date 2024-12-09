const mongoose = require("mongoose");

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
module.exports = mongoose.model("Author", authorSchema);
