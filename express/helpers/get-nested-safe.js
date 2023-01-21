module.exports = (fn, defaultVal, allow_zero, param) => {
  try {
    let res = fn(param);
    return allow_zero ? res : res || defaultVal;
  } catch (e) {
    return defaultVal;
  }
};
