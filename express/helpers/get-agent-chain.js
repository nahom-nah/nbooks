const getNestedSafe = require("../helpers/get-nested-safe");
const apollo = require("../libs/apollo");
const { gql } = require("apollo-boost");

const GET_ALL_USER = gql`
  query get_all_user($where: user_bool_exp!) {
    user(where: $where) {
      id
      username
      parentid
    }
  }
`;

module.exports = async function (userid) {
  let all_user_info = await apollo.query({
    query: GET_ALL_USER,
    variables: { where: {} },
    fetchPolicy: "no-cache",
  });

  const all_users = getNestedSafe(() => all_user_info.data.user, []);

  const createDataTree = (dataset) => {
    const hashTable = Object.create(null);
    dataset.forEach(
      (aData) => (hashTable[aData.id] = { ...aData, childNodes: [] })
    );
    const dataTree = [];
    dataset.forEach((aData) => {
      if (aData.parentid)
        hashTable[aData.parentid].childNodes.push(hashTable[aData.id]);
      else dataTree.push(hashTable[aData.id]);
    });
    return dataTree;
  };

  const final_agent_list = [userid];

  function build_agents_array(agent_tree) {
    final_agent_list.push(agent_tree.id);

    if (agent_tree.childNodes && agent_tree.childNodes.length > 0) {
      for (let index = 0; index < agent_tree.childNodes.length; index++) {
        const element = agent_tree.childNodes[index];

        build_agents_array(element);
      }
    }
  }

  let return_agent_value = {};

  function search_from_agent_tree(agent_tree) {
    for (let index = 0; index < agent_tree.length; index++) {
      const single_agent_tree = agent_tree[index];

      if (single_agent_tree.id == userid) {
        return_agent_value = single_agent_tree;
        break;
      } else if (single_agent_tree.childNodes.length > 0) {
        search_from_agent_tree(single_agent_tree.childNodes);
      }
    }
  }

  const all_user_agent_tree = createDataTree(all_users);

  search_from_agent_tree(all_user_agent_tree);

  // find from array of objects by userid
  const user_agent_tree = return_agent_value;

  if (user_agent_tree) build_agents_array(user_agent_tree);

  return [...new Set(final_agent_list)];
};
