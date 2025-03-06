/**
* @type import('hardhat/config').HardhatUserConfig
*/
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
// const { mnemonic } = require('./secrets.json');
const { API_KEY, PRIVATE_KEY} = process.env;


// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

// IRouter router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);    //eth
// IRouter router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);       //bsc
// IRouter router = IRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);       //bsc testnet

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
   defaultNetwork: "hardhat",
   networks: {
      localhost: {
         url: "http://127.0.0.1:8545"
      },
      hardhat: {
         gas: "auto"
      },
      testnet: {
         url: "https://rpc.sepolia.org",
         chainId: 11155111,
         // gasPrice: 20000000000,
         accounts: [`0x${PRIVATE_KEY}`]
      },
      mainnet: {
         url: "https://eth-mainnet.g.alchemy.com/v2/NjQKcW84LgyTNGPA2TGk45b7ZTIcZWb5",
         chainId: 1,
         // gasPrice: 20000000000,
         accounts: [`0x${PRIVATE_KEY}`]
      }
   },
   etherscan: {
      // Your API key for Etherscan
      // Obtain one at https://bscscan.com/
      apiKey: API_KEY
   },
   solidity: {
      version: "0.8.28",
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
      timeout: 999999
   }
};