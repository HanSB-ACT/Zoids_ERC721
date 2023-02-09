var token = artifacts.require("ZoidsNFT");

module.exports = function (deployer) {
    require("dotenv").config();
    const name = process.env.CONTRACT_NAME;
    const symbol = process.env.CONTRACT_SYMBOL;
    const baseUri = process.env.TOKEN_BASE_URI;
    const coinContractSymbol = process.env.COIN_CONTRACT_SYMBOL;
    const coinContractAddress = process.env.COIN_CONTRACT_ADDRESS;
    deployer.deploy(token, name, symbol, baseUri, coinContractSymbol, coinContractAddress);
};
