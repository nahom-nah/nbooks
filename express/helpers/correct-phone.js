module.exports = (phone) => {
  phone = phone.toString();
  if (phone.startsWith("+251")) return phone;
  else if (phone.startsWith("251")) {
    return phone.replace("251", "+251");
  } else if (phone.startsWith("09")) {
    return phone.replace("09", "+2519");
  } else if (phone.startsWith("9")) {
    return phone.replace("9", "+2519");
  }
};
