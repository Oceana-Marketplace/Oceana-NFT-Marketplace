require('@nomiclabs/hardhat-waffle')
require('@nomiclabs/hardhat-ethers')
require('@nomiclabs/hardhat-etherscan')
require('hardhat-abi-exporter')
require('@nomiclabs/hardhat-web3')

const credentials = require('./.env.js')
const INFURA_PROJECT_ID = credentials.Infura
const METAMASK_PRIVATE_KEY = credentials.privateKey
const ETHERSCAN_KEY = credentials.etherscan

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  abiExporter: {
    path: './abi',
    runOnCompile: true,
    clear: true,
    flat: true,
    only: [],
    spacing: 0,
    pretty: false,
  },
  etherscan: {
    apiKey: `${ETHERSCAN_KEY}`,
  },
  networks: {
    hardhat: {
      chainId: 31337,
    },
    mainnet: {
      chainId: 1,
      url: `https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`,
      //			url: `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_API}`,
      accounts: [`0x${METAMASK_PRIVATE_KEY}`],
      //		gas: 7000000,
      skipDryRun: true,
    },
    rinkeby: {
      chainId: 4,
      url: `https://rinkeby.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: [`0x${METAMASK_PRIVATE_KEY}`],
      gas: 7000000,
      skipDryRun: true,
    },
    kovan: {
      chainId: 42,
      url: `https://kovan.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: [`0x${METAMASK_PRIVATE_KEY}`],
      gas: 7000000,
      skipDryRun: true,
    },
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
}
