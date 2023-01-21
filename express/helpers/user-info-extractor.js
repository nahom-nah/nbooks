/* eslint-disable space-before-function-paren */
/* eslint-disable quotes */
"use strict";
const jwt_decode = require("jwt-decode");

module.exports = function (access_token) {
  const decoded_token = jwt_decode(access_token);

  const hasura_info = decoded_token["airevd"];

  if (hasura_info) {
    return {
      id: hasura_info["x-hasura-user-id"],
      distributorid: hasura_info["x-hasura-distributor-id"],
      role: hasura_info["x-hasura-default-role"],
    };
  } else {
    // trying to fake the system
    // thorw an unauthorized error
    throw Error("Unauthorized");
  }
};
