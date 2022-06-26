// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155Oceana.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IOceanaNFT is IERC1155Oceana, IERC2981 {
    /**
     * @dev Emitted when smart contract is deployed
     */
    event ContractDeployed(address indexed owner, string indexed _tokenUri);

    /**
     * @dev Emitted when new Fav is created
     */
    event FAVCreated(
        address indexed creator,
        uint256 indexed favId,
        uint256 indexed defaultCollectionId
    );

    /**
     * @dev Emitted when new Collection is created
     */
    event CollectionCreated(
        address indexed creator,
        uint256 indexed favId,
        uint256 indexed collectionId
    );

    /**
     * @dev Emitted when URI of Fav changes to newURI
     */
    event FavouriteURI(string indexed newURI);

    /**
     * @dev Emitted when URI of Collection changes to newURI
     */
    event CollectionURI(string indexed newURI);

    /**
     * @dev Emitted when Owner of Collection is changed to to newOwner
     */
    event CollectionOwnerChanged(
        uint256 indexed collectionId,
        address indexed newOwner
    );

    /**
     * @dev Emitted NFT is lazy-minted.
     */
    event LazyMinted(
        address indexed to,
        uint256 indexed collectionId,
        uint256 indexed tokenId,
        uint256 amount,
        uint256 royalty
    );

    /**
    @dev Emitted NFT is minted
     */

    event Minted(
        address indexed to,
        uint256 indexed collectionId,
        uint256 indexed tokenId,
        uint256 amount,
        uint256 royalty
    );

    function createFav() external;

    function createCollection(uint256 favId) external returns (uint256);

    function setFavouriteURI(string memory newURI) external;

    function setCollectionURI(string memory newURI) external;

    function changeCollectionOwner(uint256 collectionId, address newOwner)
        external;

    function lazyMint(
        uint256 tokenId,
        address to,
        uint256 collectionId,
        uint256 amount,
        uint96 royalty,
        bytes memory data
    ) external;

    function mint(
        address to,
        uint256 collectionId,
        uint256 amount,
        uint96 royalty,
        bytes memory data
    ) external;
}
