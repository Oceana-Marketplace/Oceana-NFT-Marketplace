// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155Oceana.sol";
import "./IOceanaNFT.sol";
import "./IERC165Oceana.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract OceanaNFT is ERC1155Oceana, IOceanaNFT, Ownable, ERC2981 {
    //Mapping from token ID to flag (on-chain:true, off-chain:false)
    mapping(uint256 => bool) private onChain;

    uint256 public constant ACCOUNT_ADDRESS_BITMASK = 0xFFFFFFFFFFFFFFFFFFFF;
    uint256 public constant TOKEN_SUPPLY_BITMASK = 0xFFFFFFFFFF;

    // Mapping from token ID to Collection ID
    mapping(uint256 => uint256) private token2CollectionId;

    // Mapping from collection ID to favourite ID
    mapping(uint256 => uint256) private collection2FavId;

    // Mapping from fav ID to its original Market Collection ID
    mapping(uint256 => uint256) private fav2OriginalMarketCollectionId;

    // The number of favourites in Oceana Marketplace
    uint256 private favNumber;

    // The number of collections in Oceana Marketplace
    uint256 private collectionNumber;

    // The number of token classes in Oceana Marketplac
    uint256 private tokenNumber;

    // Used as the URI for all favourites by relying on ID substitution
    string private _favURI;

    // Used as the URI for all collections by relying on ID substitution
    string private _collectionURI;

    // Mapping from collection ID to owner
    mapping(uint256 => address) private collectionOwner;

    // Mapping from token ID to creator
    mapping(uint256 => address) private tokenCreator;

    constructor(string memory _uri) ERC1155Oceana(_uri) {
        emit ContractDeployed(msg.sender, _uri);
    }

    function balanceOf(address account, uint256 id)
        public
        view
        override(IERC1155Oceana, ERC1155Oceana)
        returns (uint256)
    {
        require(
            account != address(0),
            "ERC1155: balance query for the zero address"
        );
        if (onChain[id] == false) {
            uint256 accountFetch = (id >> 11) & ACCOUNT_ADDRESS_BITMASK;
            if (account == address(uint160(accountFetch)))
                return id & TOKEN_SUPPLY_BITMASK;
        }
        return super.balanceOf(account, id);
    }

    function createFav() external override onlyOwner {
        collection2FavId[collectionNumber] = favNumber;
        fav2OriginalMarketCollectionId[favNumber] = collectionNumber;
        favNumber++;
        collectionNumber++;
        emit FAVCreated(msg.sender, favNumber - 1, collectionNumber - 1);
    }

    function createCollection(uint256 favId)
        external
        override
        returns (uint256)
    {
        require(favId < favNumber, "Fav does not exist");
        collectionOwner[collectionNumber] = msg.sender;
        collection2FavId[collectionNumber] = favId;
        collectionNumber++;
        emit CollectionCreated(msg.sender, favId, collectionNumber - 1);
        return collectionNumber - 1;
    }

    function setFavouriteURI(string memory newURI) external override onlyOwner {
        _favURI = newURI;
        emit FavouriteURI(newURI);
    }

    function setCollectionURI(string memory newURI)
        external
        override
        onlyOwner
    {
        _collectionURI = newURI;
        emit CollectionURI(newURI);
    }

    function changeCollectionOwner(uint256 collectionId, address newOwner)
        external
        override
        onlyOwner
    {
        require(
            collectionOwner[collectionId] != newOwner,
            "old Owner and new Owner are the same"
        );
        collectionOwner[collectionId] = newOwner;
        emit CollectionOwnerChanged(collectionId, newOwner);
    }

    function lazyMint(
        uint256 tokenId,
        address to,
        uint256 collectionId,
        uint256 amount,
        uint96 royalty,
        bytes memory data
    ) external override {
        require(collectionId < collectionNumber, "Collection ID doesn't exist");
        require(amount >= 1, "Can not mint zero amount");
        require(
            msg.sender == collectionOwner[collectionId] ||
                fav2OriginalMarketCollectionId[
                    collection2FavId[collectionId]
                ] ==
                collectionId,
            "Original Collection ID or Collection Owner doesn't match Msg Sender"
        );
        _mintOceana(to, tokenId, amount, data);
        token2CollectionId[tokenId] = collectionId;
        _setTokenRoyalty(tokenId, to, royalty);
        emit LazyMinted(to, collectionId, tokenId, amount, royalty);
    }

    function mint(
        address to,
        uint256 collectionId,
        uint256 amount,
        uint96 royalty,
        bytes memory data
    ) external override {
        require(collectionId < collectionNumber, "Collection ID doesn't exist");
        require(amount >= 1, "Can not mint zero amount");
        require(
            msg.sender == collectionOwner[collectionId] ||
                fav2OriginalMarketCollectionId[
                    collection2FavId[collectionId]
                ] ==
                collectionId,
            "Collection is not created by the user or this is not an original Market Collection of any Favourite"
        );
        _mintOceana(to, tokenNumber, amount, data);
        token2CollectionId[tokenNumber] = collectionId;
        _setTokenRoyalty(tokenNumber, to, royalty);
        tokenNumber++;
        emit Minted(to, collectionId, tokenNumber - 1, amount, royalty);
    }

    function burnNFT(uint256 tokenId, uint256 amount) external {
        _burn(msg.sender, tokenId, amount);
    }
}
