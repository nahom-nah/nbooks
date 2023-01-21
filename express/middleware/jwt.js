const jwt = require("jsonwebtoken");
const getNestedSafe = require("../helpers/get-nested-safe");
const apollo = require("../libs/apollo");
const { gql } = require("apollo-boost");

const GET_SINGLE_USER = gql`
  query get_user($id: uuid!) {
    user_by_pk(id: $id) {
      id
      is_active
      distributor {
        id
        active
      }
      parent {
        id
        is_active
      }
    }
  }
`;

module.exports = async function (req, res, next) {
  let authorization = req.headers.authorization;

  if (authorization) {
    let authorization_header_parts = authorization.split(" ");

    authorization =
      authorization_header_parts[0].toLowerCase() === "bearer"
        ? authorization_header_parts[1]
        : authorization_header_parts[0];

    try {
      let decoded = jwt.verify(authorization, process.env.ENCRYPTION_KEY);

      req.jwt = decoded;

      const single_user_info = await apollo.query({
        query: GET_SINGLE_USER,
        variables: { id: decoded.sub },
        fetchPolicy: "no-cache",
      });

      const user_info = getNestedSafe(
        () => single_user_info.data.user_by_pk,
        null
      );

      if (!user_info.is_active) {
        throw new Error("Inactive Account!");
      } else if (user_info.distributor && !user_info.distributor.active) {
        throw new Error("Inactive Distributor!");
      } else if (user_info.parent && !user_info.parent.is_active) {
        throw new Error("Inactive Parent!");
      }

      return next();
    } catch (error) {
      res.status(422).json({
        message: error.message,
        code: "AUTHORIZATION_ERROR",
      });
    }
  } else {
    return res.status(422).send({
      message: "unauthorized",
    });
  }
};
