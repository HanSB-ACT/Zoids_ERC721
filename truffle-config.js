require("dotenv").config();
const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    polygonscan: process.env.POLYGONSCAN_API_KEY,
  },

  networks: {
    dev: {
      host: "127.0.0.1",
      port: 9545,
      network_id: "*" // Match any network id
    },
    polygontest: {
      provider: () => new HDWalletProvider(process.env.PRIVATEKEY, `https://rpc-mumbai.maticvigil.com`),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    polygon: {
      //provider: () => new HDWalletProvider(process.env.PRIVATEKEY, `https://rpc-mainnet.maticvigil.com`),
      provider: () => new HDWalletProvider(process.env.PRIVATEKEY, `https://polygon-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`),
      network_id: 137,
      confirmations: 2,
      timeoutBlocks: 200,
      gasPrice: 45000000000,
      skipDryRun: true
    }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    //timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "^0.8.0",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200
        },
        //evmVersion: "byzantium"
      }
    }
  },

  // Truffle DB is currently disabled by default; to enable it, change enabled:
  // false to enabled: true. The default storage location can also be
  // overridden by specifying the adapter settings, as shown in the commented code below.
  //
  // NOTE: It is not possible to migrate your contracts to truffle DB and you should
  // make a backup of your artifacts to a safe location before enabling this feature.
  //
  // After you backed up your artifacts you can utilize db by running migrate as follows:
  // $ truffle migrate --reset --compile-all
  //
  // db: {
  // enabled: false,
  // host: "127.0.0.1",
  // adapter: {
  //   name: "sqlite",
  //   settings: {
  //     directory: ".db"
  //   }
  // }
  // }
}
