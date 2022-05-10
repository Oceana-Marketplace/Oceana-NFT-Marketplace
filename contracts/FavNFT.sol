// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155Oceana.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FavNFT is ERC1155Oceana, Ownable{
    using Address for address;
    uint256 favNumber;

    mapping(uint256 => uint256) fav2tokenId;
    mapping(uint256 => string) fav2dataUrl;

    event CreateFav(
        uint256 favId,
        string dataUrl
    );
    
    constructor() {}
    function createFav(string memory dataUrl) external onlyOwner{
        fav2dataUrl[favNumber] = dataUrl;
        emit CreateFav(favNumber, dataUrl);
        favNumber++;
    }

    function getFavDataUrl(uint256 favId) external view returns (string memory){
        return fav2dataUrl[favId];
    }

    function setFavDataUrl(uint256 favId, string memory newDataUrl) external onlyOwner{
        fav2dataUrl[favId] = newDataUrl;
    }
    

    function createNft(address to, uint256 favId, uint256 amount, bytes memory data) external{
        require(favId < favNumber && amount >= 1);
        uint256 ID = fav2tokenId[favId];
        _mint(to, favId, ID, amount, data);
        fav2tokenId[favId]++;
    }
}

//get, set data URL functions
//event
//