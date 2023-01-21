"use strict";

module.exports = () => {
  const batchRandom = new Date().getTime().toString();

  // generate 4 digit random number
  const random = Math.floor(1000 + Math.random() * 9000);

  let batch = "";
  for (let i = 0; i < batchRandom.length; i++) {
    if (i === 5 || i === 8) {
      batch += "-";
    }
    batch += batchRandom[i];
  }

  return batch + "-" + random;
};
