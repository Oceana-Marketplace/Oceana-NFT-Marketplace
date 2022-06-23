// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155Oceana.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "./IOceanaNFT.sol";

contract OceanaNFT is ERC1155Oceana, Ownable, ERC2981 {
    /**
     * @dev Emitted when smart contract deployed
     */
    event ContractDeployed(address indexed owner, string _tokenUri);

    /**
     * @dev Emitted when new Fav created
     */
    event CreateFAV(
        address indexed creator,
        uint256 indexed favId,
        uint256 indexed defaultCollectionId
    );

    /**
     * @dev Emitted when new Collection created
     */
    event CreateCollection(
        address indexed creator,
        uint256 indexed favId,
        uint256 indexed CollectionId
    );

    /**
     * @dev Emitted when new FAV uri seted
     */
    event SetFavouriteURI(string newURI);

    /**
     * @dev Emitted when new Collection uri seted
     */
    event SetCollectionURI(string newURI);

    /**
     * @dev Emitted new NFT created.
     */
    event CreateNFT(
        address indexed to,
        uint256 indexed collectionId,
        uint256 indexed tokenNumber,
        uint256 amount,
        uint256 royalty
    );

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

    // Mapping from collection ID to creator
    mapping(uint256 => address) private collectionCreators;

    constructor(string memory _uri) ERC1155Oceana(_uri) {
        emit ContractDeployed(msg.sender, _uri);
    }

    function createFav() external onlyOwner {
        collection2favId[collectionNumber] = favNumber;
        fav2originalMarketCollectionId[favNumber] = collectionNumber;
        favNumber++;
        collectionNumber++;
        emit CreateFAV(msg.sender, favNumber - 1, collectionNumber - 1);
    }

    function createCollection(uint256 favId) external {
        require(favId < favNumber, "Fav does not exist");
        collectionCreators[collectionNumber] = msg.sender;
        collection2favId[collectionNumber] = favId;
        collectionNumber++;
        emit CreateCollection(msg.sender, favId, collectionNumber - 1);
    }

    function setFavouriteURI(string memory newURI) external onlyOwner {
        _favURI = newURI;
        emit SetFavouriteURI(newURI);
    }

    function setCollectionURI(string memory newURI) external onlyOwner {
        _collectionURI = newURI;
        emit SetCollectionURI(newURI);
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
            msg.sender == collectionCreators[collectionId] ||
                fav2originalMarketCollectionId[
                    collection2favId[collectionId]
                ] ==
                collectionId,
            "Collection is not created by the user or this is not an original Market Collection of any Favourite"
        );
        _mintOceana(to, tokenNumber, amount, data);
        token2collectionId[tokenNumber] = collectionId;
        _setTokenRoyalty(tokenNumber, to, royalty);
        tokenNumber++;
        emit CreateNFT(to, collectionId, tokenNumber - 1, amount, royalty);
    }

    function burnNFT(
        uint256 tokenId,
        uint256 amount
    ) external {
        _burn( msg.sender, tokenId, amount);
    }
}
