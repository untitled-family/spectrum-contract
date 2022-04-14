require("@nomiclabs/hardhat-waffle");
require('dotenv').config();

const { ALCHEMY_URL, ALCHEMY_KEY, PRIVATE_KEY_DEV } = process.env;

module.exports = {
  solidity: "0.8.12",
  networks: {
    rinkeby: {
      url: ALCHEMY_URL + ALCHEMY_KEY,
      accounts: [`${PRIVATE_KEY_DEV}`],
    },
  },
};