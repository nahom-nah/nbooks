module.exports = (vouchers) => {
  for (let index = 0; index < vouchers.length; index++) {
    if (
      index != vouchers.length - 1 &&
      vouchers[index].serial != vouchers[index + 1].serial - 1
    ) {
      return index + 1;
    }
  }

  return -1;
};
