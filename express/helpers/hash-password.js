const bcrypt = require("bcryptjs");

module.exports = (plain) => {
  const salt = bcrypt.genSaltSync(15);
  return bcrypt.hashSync(plain, salt);
};
