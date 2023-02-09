// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";

contract CoinContactManager is Ownable {
    mapping(string => address) private contracts;

    function getCoinContract(string memory _symbol)
        public
        view
        returns (address)
    {
        return contracts[_symbol];
    }

    function setCoinContract(string memory _symbol, address _newAddress)
        public
        onlyOwner
    {
        require(
            _newAddress != address(0),
            "setCoinContract: new address is the zero address"
        );

        contracts[_symbol] = _newAddress;
    }

    function removeCoinContract(string memory _symbol) public onlyOwner {
        require(
            contracts[_symbol] != address(0),
            "removeCoinContract: address is not added"
        );

        delete contracts[_symbol];
    }
}
