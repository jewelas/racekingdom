/**
* @type import('hardhat/config').HardhatUserConfig
*/
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("@openzeppelin/hardhat-upgrades");
const { mnemonic } = require('./secrets.json');
const { BSC_API_KEY, API_URL_ROPSTEN, API_URL_RINKEBY, PRIVATE_KEY, API_KEY } = process.env;


// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
   defaultNetwork: "testnet",
   networks: {
      localhost: {
         url: "http://127.0.0.1:8545"
      },
      hardhat: {
      },
      testnet: {
         url: "https://data-seed-prebsc-1-s1.binance.org:8545",
         chainId: 97,
         gasPrice: 20000000000,
         accounts: { mnemonic: mnemonic }
      },
      mainnet: {
         url: "https://bsc-dataseed.binance.org/",
         chainId: 56,
         gasPrice: 20000000000,
         accounts: { mnemonic: mnemonic }
      },
      ropsten: {
         url: API_URL_ROPSTEN,
         accounts: [`0x${PRIVATE_KEY}`]
      },
      rinkeby: {
         url: API_URL_RINKEBY,
         accounts: [`0x${PRIVATE_KEY}`]
      }
   },
   etherscan: {
      // Your API key for Etherscan
      // Obtain one at https://bscscan.com/
      apiKey: {
         ropsten: API_KEY,
         rinkeby: API_KEY,
         testnet: BSC_API_KEY,
         mainnet: BSC_API_KEY
      }
   },
   solidity: {
      version: "0.8.0",
      settings: {
         optimizer: {
            enabled: true
         }
      }
   },
   paths: {
      sources: "./contracts",
      tests: "./test",
      cache: "./cache",
      artifacts: "./artifacts"
   },
   mocha: {
      timeout: 20000
   }
};