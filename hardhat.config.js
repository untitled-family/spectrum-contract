require("@nomiclabs/hardhat-waffle");
require('dotenv').config();

const {
  ALCHEMY_URL,
  ALCHEMY_KEY,
  PRIVATE_KEY_DEV,
  PRIVATE_KEY_POLYGON,
  ALCHEMY_KEY_POLYGON,
  ALCHEMY_URL_POLYGON,
  POLYGONSCAN_KEY
} = process.env;

module.exports = {
  solidity: "0.8.12",
  // networks: {
  //   rinkeby: {
  //     url: ALCHEMY_URL + ALCHEMY_KEY,
  //     accounts: [`${PRIVATE_KEY_DEV}`],
  //   },
  // },
  defaultNetwork: "matic",
  networks: {
    hardhat: {
    },
    matic: {
      url: ALCHEMY_URL_POLYGON + ALCHEMY_KEY_POLYGON,
      accounts: [`${PRIVATE_KEY_POLYGON}`]
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: POLYGONSCAN_KEY
  }
};

// deployed contract on Polygon
// 0x721cC02712c3343d2fbfCfde512F247D94967EE4