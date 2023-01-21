const correctPhone = require("./correct-phone");

const phoneExp = /^(^\+251|^251|^0)?9\d{8}$/;
const emailExp =
  /^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/;

module.exports = (credentials) => {
  const query = {};
  credentials = credentials || {};

  if (emailExp.exec(credentials.username)) {
    query.email = { _eq: credentials.username.toLowerCase() };
  } else if (phoneExp.exec(credentials.username)) {
    query.phone = { _eq: correctPhone(credentials.username) };
  } else if (credentials.username) {
    query.username = { _eq: credentials.username.toLowerCase() };
  } else {
    let error = new Error("Empty Credentials");
    error.name = "Failed";
    error.message = "Empty Credentials";
    error.statusCode = 422;
    throw error;
  }

  return query;
};
