const adminUser = require("../data/admin.json");
const hashPassword = require("../helpers/hash-password");
const getNestedSafe = require("../helpers/get-nested-safe");
const apollo = require("../libs/apollo");
const { gql } = require("apollo-boost");

const GET_ROLE = gql`
  query get_role($slug: String!) {
    role(where: { slug: { _eq: $slug } }) {
      id
      slug
    }
  }
`;

const INSERT_ADMIN = gql`
  mutation inser_admin($object: user_insert_input!) {
    insert_user_one(
      on_conflict: { constraint: user_username_key, update_columns: updated_at }
      object: $object
    ) {
      id
    }
  }
`;

module.exports = async () => {
  console.log("Seeding admin user ...");
  const user_info = adminUser;

  const admin_role_info = await apollo.query({
    query: GET_ROLE,
    variables: { slug: "Admin" },
  });

  const admin_role = getNestedSafe(() => admin_role_info.data.role[0], null);

  if (!admin_role) {
    console.log("Unable to find Admin role!");
    return false;
  }

  user_info.roleid = admin_role.id;
  user_info.password = hashPassword(user_info.password);

  return await apollo.mutate({
    mutation: INSERT_ADMIN,
    variables: {
      object: user_info,
    },
  });
};
