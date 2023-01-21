module.exports = (receiver_role, distributor, setting) => {
  if (receiver_role == "Retailer" && !distributor.allow_agent_chain) {
    return parseFloat(setting.to_agents);
  } else if (receiver_role == "Retailer" && distributor.allow_agent_chain) {
    return parseFloat(setting.to_ind_agents);
  } else if (receiver_role == "Agent" && !distributor.allow_agent_chain) {
    return parseFloat(setting.to_dir_dist);
  } else if (receiver_role == "Agent" && distributor.allow_agent_chain) {
    return parseFloat(setting.to_ind_dist);
  } else if (receiver_role == "Sales" && !distributor.allow_agent_chain) {
    return 0;
  } else if (receiver_role == "Sales" && distributor.allow_agent_chain) {
    return parseFloat(setting.to_ind_sales);
  } else return 0;
};
