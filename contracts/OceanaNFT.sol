// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155Oceana.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract OceanaNFT is ERC1155Oceana, Ownable, ERC2981 {
    using Address for address;

    // Mapping from token ID to Collection ID
    mapping(uint256 => uint256) private token2collectionId;

    // Mapping from fav ID to its original Market Collection ID
    mapping(uint256 => uint256) private fav2originalMarketCollectionId;

    // Mapping from collection ID to favourite ID
    mapping(uint256 => uint256) private collection2favId;

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
        require(
            msg.sender == creators[tokenId],
            "msg sender is not the creator of NFT"
        );
        _;
    }

    constructor(string memory _uri) ERC1155Oceana(_uri) {}

    function createFav() external onlyOwner {
        collection2favId[collectionNumber] = favNumber;
        fav2originalMarketCollectionId[favNumber] = collectionNumber;
        favNumber++;
        collectionNumber++;
    }

    function createCollection(uint256 favId) external {
        collection2favId[collectionNumber] = favId;
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
        uint96 royalty,
        bytes memory data
    ) external {
        require(collectionId < collectionNumber, "Collection ID doesn't exist");
        require(amount >= 1, "Can not mint zero amount");
        require(
            msg.sender == creators[collectionId] ||
                fav2originalMarketCollectionId[
                    collection2favId[collectionId]
                ] ==
                collectionId,
            "Collection is not created by the user or this is not an original Market Collection of any Favourite"
        );
        _mintOceana(to, tokenNumber, amount, data);
        token2collectionId[tokenNumber] = collectionId;
        creators[tokenNumber] = msg.sender;
        _setTokenRoyalty(tokenNumber, msg.sender, royalty);
        tokenNumber++;
    }
}
