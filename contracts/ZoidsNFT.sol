// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./CoinContactManager.sol";
import "./Ownable.sol";
import "./TimeLock.sol";

// Truffle
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

// Remix
// import "@openzeppelin/contracts@4.7.3/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts@4.7.3/token/ERC721/extensions/ERC721Pausable.sol";
// import "@openzeppelin/contracts@4.7.3/token/common/ERC2981.sol";
// import "@openzeppelin/contracts@4.7.3/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts@4.7.3/utils/Counters.sol";
// import "@openzeppelin/contracts@4.7.3/utils/math/SafeCast.sol";

contract ZoidsNFT is
    ERC721,
    ERC721Enumerable,
    ERC721Pausable,
    ERC2981,
    ReentrancyGuard,
    Ownable,
    TimeLock,
    CoinContactManager
{
    using Counters for Counters.Counter;
    using SafeCast for uint256;

    string public VER = "1.0";
    string public baseTokenURI;
    Counters.Counter private totalTokenCount;
    address private royaltyWallet;

    event eventCreateCard(address _toAddress, uint256 _tokenId);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        string memory _coinSymbol,
        address _coinContract
    ) public ERC721(_name, _symbol) {
        setBaseURI(_uri);
        setRoyaltyWallet(msg.sender);
        setCoinContract(_coinSymbol, _coinContract);
    }

    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked(_baseURI(), "contract-meta"));
    }

    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _uri) public onlyOwner {
        baseTokenURI = _uri;
    }

    function totalSupply() public view override returns (uint256) {
        return totalTokenCount.current();
    }

    function tokensOfOwner(
        address _owner,
        uint256 _min,
        uint256 _max
    ) public view returns (uint256[] memory) {
        require(
            _min <= _max,
            "tokensOfOwner: min value is bigger than max value"
        );

        uint256 arrayLength = _max - _min + 1;
        uint256 count = 0;
        uint256[] memory tokenIds = new uint256[](arrayLength);
        for (uint256 index = _min; index <= _max; index++) {
            tokenIds[count] = tokenOfOwnerByIndex(_owner, index);
            count++;
        }
        return tokenIds;
    }

    function _createCard(
        address _toAddress,
        uint256 _tokenId,
        uint96 _royalty
    ) private nonReentrant {
        totalTokenCount.increment();

        _safeMint(_toAddress, _tokenId);
        _setRoyaltyInfo(_tokenId, royaltyWallet, _royalty);

        emit eventCreateCard(_toAddress, _tokenId);
    }

    function createCard(
        address _toAddress,
        uint256 _tokenId,
        uint96 _royalty
    ) public onlyOwner {
        _createCard(_toAddress, _tokenId, _royalty);
    }

    function createCardWithBurn(
        address _toAddress,
        uint256 _tokenId,
        uint256[] memory _burnTokenIds,
        uint96 _royalty
    ) public onlyOwner {
        burnCards(_burnTokenIds);
        _createCard(_toAddress, _tokenId, _royalty);
    }

    function unpack(
        address _toAddress,
        uint256 _startTokenId,
        uint256 _amount,
        uint96 _royalty
    ) public onlyOwner {
        for (uint256 i = 0; i < _amount; i++) {
            _createCard(_toAddress, _startTokenId + i, _royalty);
        }
    }

    function airdrop(
        address[] memory _toAddresses,
        uint256 _startTokenId,
        uint96 _royalty
    ) public onlyOwner {
        for (uint256 i = 0; i < _toAddresses.length; i++) {
            _createCard(_toAddresses[i], _startTokenId + i, _royalty);
        }
    }

    function burnCards(uint256[] memory _burnTokenIds) public onlyOwner {
        for (uint256 i = 0; i < _burnTokenIds.length; i++) {
            totalTokenCount.decrement();
            _burn(_burnTokenIds[i]);
        }
    }

    function market(
        address _buyer,
        uint256 _tokenId,
        uint256 _coinAmount,
        string memory _coinSymbol
    ) public onlyOwner {
        address coinContract = getCoinContract(_coinSymbol);
        require(
            coinContract != address(0),
            "market: coinContract is the zero address"
        );

        address royaltyReciever;
        uint256 royaltyAmount;
        (royaltyReciever, royaltyAmount) = royaltyInfo(_tokenId, _coinAmount);
        ERC20(coinContract).transferFrom(
            _buyer,
            royaltyReciever,
            royaltyAmount
        );

        address tokenOwner = ownerOf(_tokenId);
        uint256 tokenOwnerAmount = _coinAmount - royaltyAmount;
        ERC20(coinContract).transferFrom(_buyer, tokenOwner, tokenOwnerAmount);

        safeTransferFrom(tokenOwner, _buyer, _tokenId);
    }

    function marketMulti(
        address _buyer,
        uint256[] memory _tokenIds,
        uint256[] memory _coinAmounts,
        string memory _coinSymbol
    ) public onlyOwner {
        require(
            _tokenIds.length == _coinAmounts.length,
            "marketMulti: values length mismatch"
        );

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            market(_buyer, _tokenIds[i], _coinAmounts[i], _coinSymbol);
        }
    }

    function pause() public virtual onlyOwner {
        _pause();
    }

    function unpause() public virtual onlyOwner {
        _unpause();
    }

    function setRoyaltyWallet(address _wallet) public onlyOwner {
        require(
            _wallet != address(0),
            "setRoyaltyWallet: Wallet address is the zero address"
        );

        royaltyWallet = _wallet;
    }

    function _setRoyaltyInfo(
        uint256 _tokenId,
        address _receiver,
        uint96 _royalty
    ) private {
        _setTokenRoyalty(_tokenId, _receiver, _royalty);
    }

    function supportsInterface(bytes4 _interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }

    function _beforeTokenTransfer(
        address _fromAddress,
        address _toAddress,
        uint256 _tokenId
    )
        internal
        virtual
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        whenNotPaused
        notLocked
    {
        super._beforeTokenTransfer(_fromAddress, _toAddress, _tokenId);
    }
}
