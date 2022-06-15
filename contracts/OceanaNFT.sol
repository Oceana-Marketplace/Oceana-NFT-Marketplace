// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155Oceana.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OceanaNFT is ERC1155Oceana, Ownable {
    using Address for address;

    // Mapping from token ID to Collection ID
    mapping(uint256 => uint256) private token2collectionID;

    // Mapping from fav ID to original Market Collection ID
    mapping(uint256 => uint256) private fav2originalMarketCollectionID;

    // Mapping from collection ID to favourite ID
    mapping(uint256 => uint256) private collection2favID;

    // The number of favourites in Oceana Marketplace
    uint256 private favNumber;

    // Mapping from Collection ID to creator (this exists for collections created by users, not for original fav collection)
    mapping(uint256 => address) private collectionCreator;

    // The number of collections in Oceana Marketplace
    uint256 private collectionNumber;

    // The number of token classes
    uint256 private tokenNumber;

    // Used as the URI for all favourites by relying on ID substitution
    string private _favURI;
    string private _collectionURI;

    modifier onlyCreator(uint256 tokenId) {
        require(
            msg.sender == collectionCreator[token2collectionID[tokenId]],
            "only creator can set uri"
        );
        _;
    }

    constructor(string memory _uri) ERC1155Oceana(_uri) {}

    function createFav() external onlyOwner {
        collection2favID[collectionNumber] = favNumber;
        fav2originalMarketCollectionID[favNumber] = collectionNumber;
        /* This is for future usage
        fav2originalMarketCollectionID[favNumber] = collectionNumber;
        */
        favNumber++;
        collectionNumber++;
    }

    function createCollection(uint256 favId) external {
        collectionCreator[collectionNumber] = msg.sender;
        collection2favID[collectionNumber] = favId;
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
        uint256 collectionID,
        uint256 amount,
        bytes memory data
    ) external {
        require(collectionID < collectionNumber, "Collection ID doesn't exist");
        require(amount >= 1, "Can not mint zero amount");
        require(
            msg.sender == collectionCreator[collectionID] ||
                collectionID ==
                fav2originalMarketCollectionID[collection2favID[collectionID]],
            "Creator of Collection ID doesn't match with caller or Collection ID is not original market collection ID of any favourite"
        );
        _mintOceana(to, tokenNumber, amount, data);
        token2collectionID[tokenNumber] = collectionID;
        tokenNumber++;
    }
}
