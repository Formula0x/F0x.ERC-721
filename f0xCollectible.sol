pragma solidity ^0.5.9;

import 'github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol';
import 'github.com/OpenZeppelin/openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract OwnableDelegateProxy { }

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @title TradeableERC721Token
 * TradeableERC721Token - ERC721 contract that whitelists a trading address, and has minting functionality.
 */
contract TradeableERC721Token is ERC721Full, Ownable {

  address proxyRegistryAddress;
  uint256 private _currentTokenId = 0;
 
 //Tracks metadata uri per token ID
  mapping(uint256 => string) tokenUris;

  constructor(string memory _name, string memory _symbol, address _proxyRegistryAddress) ERC721Full(_name, _symbol) public {
    proxyRegistryAddress = _proxyRegistryAddress;
  }
  
  
  /**
    * @dev Mints bulk amount to address (owner)
    * @param _to address of the future owner of the token
    */
  function bulkMintTo(uint256 mintAmount, address _to, string memory _uri) public onlyOwner {
    for (uint256 i = 0; i < mintAmount; i++) {
        uint256 newTokenId = _getNextTokenId();
        tokenUris[newTokenId] = _uri;
        _mint(_to, newTokenId);
        _incrementTokenId();
     }
  }

  /**
    * @dev Mints bulk amount of same token with given meta to array of addresses
    */
  function bulkMintArray(address[] memory receivers, string memory _uri) public onlyOwner {
     for (uint256 i = 0; i < receivers.length; i++) {
        uint256 newTokenId = _getNextTokenId();
        tokenUris[newTokenId] = _uri;
        _mint(receivers[i], newTokenId);
        _incrementTokenId();
     }
  }

  /**
    * @dev Mints a token to an address with a tokenURI.
    * @param _to address of the future owner of the token
    */
  function mintTo(address _to, string memory _uri) public onlyOwner {
    uint256 newTokenId = _getNextTokenId();
    tokenUris[newTokenId] = _uri;
    _mint(_to, newTokenId);
    _incrementTokenId();
  }

  /**
    * @dev calculates the next token ID based on value of _currentTokenId 
    * @return uint256 for the next token ID
    */
  function _getNextTokenId() private view returns (uint256) {
    return _currentTokenId.add(1);
  }

  /**
    * @dev increments the value of _currentTokenId 
    */
  function _incrementTokenId() private  {
    _currentTokenId++;
  }

  function baseTokenURI() public view returns (string memory) {
    return "";
  }

//Fetches the token URI based on tokenID
  function tokenURI(uint256 _tokenId) external view returns (string memory) {
    return tokenUris[_tokenId];
  }

  /**
   * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
   */
  function isApprovedForAll(
    address owner,
    address operator
  )
    public
    view
    returns (bool)
  {
    // Whitelist OpenSea proxy contract for easy trading.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (address(proxyRegistry.proxies(owner)) == operator) {
        return true;
    }

    return super.isApprovedForAll(owner, operator);
  }
}

/**
 * @title f0x
 * Formula0x - Tokenized Formula 1 and various racing concept liveries 
 */
contract f0xCollectible is TradeableERC721Token {
  constructor(address _proxyRegistryAddress) TradeableERC721Token("Formula0x", "f0x", _proxyRegistryAddress) public {  }

}