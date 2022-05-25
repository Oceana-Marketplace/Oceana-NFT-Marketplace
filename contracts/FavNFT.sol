// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155Oceana.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FavNFT is ERC1155Oceana, Ownable {
    using Address for address;
    uint256 favNumber;

    mapping(uint256 => uint256) public fav2tokenId;
    mapping(uint256 => string) public fav2dataURI;
    mapping(uint256 => mapping(uint256 => address)) public creators;

    event CreateFav(uint256 favId, string dataURI);
    event SetFavDataURI(uint256 favId, string dataURI);

    modifier onlyCreator(uint256 favId, uint256 tokenId) {
        require(
            msg.sender == creators[favId][tokenId],
            "only creator can set uri"
        );
        _;
    }

    constructor() {}

    function createFav(string memory dataUrl) external onlyOwner {
        fav2dataURI[favNumber] = dataUrl;
        emit CreateFav(favNumber, dataUrl);
        favNumber++;
    }

    function setFavDataURI(uint256 favId, string memory newDataURI)
        external
        onlyOwner
    {
        require(favId < favNumber, "Fav doesn't exist");
        fav2dataURI[favId] = newDataURI;
        emit SetFavDataURI(favId, newDataURI);
    }

    function createNft(
        address to,
        uint256 favId,
        uint256 amount,
        string memory uri,
        bytes memory data
    ) external {
        require(favId < favNumber, "Fav doesn't exist");
        require(amount >= 1, "amount is zero");
        uint256 tokenId = fav2tokenId[favId];
        _mint(to, favId, tokenId, amount, data);
        _setURI(favId, tokenId, uri);
        fav2tokenId[favId]++;
        creators[favId][tokenId] = msg.sender;
    }

    function setTokenURI(
        uint256 favId,
        uint256 tokenId,
        string memory uri
    ) external onlyCreator(favId, tokenId) {
        require(favId < favNumber, "Fav doesn't exist");
        _setURI(favId, tokenId, uri);
    }
}
