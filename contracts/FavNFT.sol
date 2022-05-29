// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155Oceana.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FavNFT is ERC1155Oceana, Ownable {
    using Address for address;

    // Mapping from token ID to Collection ID
    mapping(uint256 => uint256) private _collection;

    // Mapping from collection ID to favourite ID
    mapping(uint256 => uint256) private _favourite;

    // The number of favourites in Oceana Marketplace
    uint256 private favNumber;

    // The number of collections in Oceana Marketplace
    uint256 private collectionNumber;

    // The number of token classes
    uint256 private tokenNumber;

    // Used as the URI for all favourites by relying on ID substitution
    string private _favURI;
    string private _collectionURI;

    // Mapping from tokenID to creator
    mapping(uint256 => address) private creators;

    modifier onlyCreator(uint256 tokenId) {
        require(msg.sender == creators[tokenId], "only creator can set uri");
        _;
    }

    constructor(string memory _uri) ERC1155Oceana(_uri) {}

    function createFav() external onlyOwner {
        _favourite[collectionNumber] = favNumber;
        favNumber++;
        collectionNumber++;
    }

    function createCollection(uint256 favId) external {
        _favourite[collectionNumber] = favId;
        collectionNumber++;
    }

    function setFavouriteURI(string memory newURI) external onlyOwner {
        _favURI = newURI;
    }

    function setCollectionURI(string memory newURI) external onlyOwner {
        _collectionURI = newURI;
    }

    function createNft(
        address to,
        uint256 collectionId,
        uint256 amount,
        bytes memory data
    ) external {
        require(collectionId < collectionNumber, "Collection ID doesn't exist");
        require(amount >= 1, "Can not mint zero amount");
        _mintOceana(to, tokenNumber, amount, data);
        _collection[tokenNumber] = collectionId;
        creators[tokenNumber] = msg.sender;
        tokenNumber++;
    }
}
