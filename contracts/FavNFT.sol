// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155Oceana.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FavNFT is ERC1155Oceana, Ownable {
    using Address for address;
    uint256 favNumber;

    mapping(uint256 => uint256) fav2tokenId;
    mapping(uint256 => string) fav2dataUrl;
    mapping(uint256 => mapping(uint256 => address)) creators;

    event CreateFav(uint256 favId, string dataUrl);

    modifier onlyCreator(uint256 favId, uint256 tokenId) {
        require(
            msg.sender == creators[favId][tokenId],
            "only creator can set uri"
        );
        _;
    }

    constructor() {}

    function createFav(string memory dataUrl) external onlyOwner {
        fav2dataUrl[favNumber] = dataUrl;
        emit CreateFav(favNumber, dataUrl);
        favNumber++;
    }

    function getFavDataUrl(uint256 favId)
        external
        view
        returns (string memory)
    {
        return fav2dataUrl[favId];
    }

    function setFavDataUrl(uint256 favId, string memory newDataUrl)
        external
        onlyOwner
    {
        fav2dataUrl[favId] = newDataUrl;
    }

    function createNft(
        address to,
        uint256 favId,
        uint256 amount,
        string memory uri,
        bytes memory data
    ) external {
        require(favId < favNumber && amount >= 1);
        uint256 tokenId = fav2tokenId[favId];
        _mint(to, favId, tokenId, amount, data);
        _setURI(favId, tokenId, uri);
        fav2tokenId[favId]++;
        creators[favId][tokenId] = msg.sender;
    }

    function setTokenUri(
        uint256 favId,
        uint256 tokenId,
        string memory uri
    ) external onlyCreator(favId, tokenId) {
        _setURI(favId, tokenId, uri);
    }
}
