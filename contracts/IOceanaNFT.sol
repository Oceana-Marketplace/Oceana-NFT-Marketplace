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
     * @dev Emitted when smart contract deployed
     */
    event ContractDeployed(address indexed owner, string indexed _tokenUri);

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
    event SetFavouriteURI(string indexed newURI);

    /**
     * @dev Emitted when new Collection uri seted
     */
    event SetCollectionURI(string indexed newURI);

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

    /**
     * @dev Returns Created new collection in specific FAV
     *
     * Requirements:
     *
     * - `favId` cannot lower then total favNumber
     */
    function createCollection(uint256 favId) external;

    /**
     * @dev Created new NFT on specific collection and fav
     *
     * Requirements:
     *
     * - `collectionId`'s owner must be msg.sender
     */
    function createNft(
        address to,
        uint256 collectionId,
        uint256 amount,
        uint96 royalty,
        bytes memory data
    ) external;

    /**
     * @dev Created new NFT on specific collection and fav
     *
     * Requirements:
     *
     * - `collectionId`'s owner must be msg.sender
     */
    function royaltyInfo(
        address to,
        uint256 collectionId,
        uint256 amount,
        uint96 royalty,
        bytes memory data
    ) external;
}
