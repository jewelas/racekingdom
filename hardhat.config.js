/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
// const { mnemonic } = require('./secrets.json');
const { AVAX_API_KEY, PRIVATE_KEY } = process.env;

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    hardhat: {
      gas: "auto",
    },
    testnet: {
      chainId: 43113,
      url: "https://api.avax-test.network/ext/bc/C/rpc",
      // gasPrice: 20000000000,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    mainnet: {
      chainId: 43114,
      url: "https://api.avax.network/ext/bc/C/rpc",

      // gasPrice: 20000000000,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://bscscan.com/
    apiKey: AVAX_API_KEY,
  },
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  mocha: {
    timeout: 999999,
  },
};
