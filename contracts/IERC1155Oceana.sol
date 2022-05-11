pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
interface IERC1155Oceana is IERC165 {
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 favId,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 favId,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(
        uint256 favId,
        address indexed account,
        address indexed operator,
        bool approved
    );

    event URI(uint256 indexed favId, uint256 indexed id, string value);
    function balanceOf(
        uint256 favId,
        address account,
        uint256 id
    ) external view returns (uint256);

    function balanceOfBatch(
        uint256 favId,
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    function setApprovalForAll(
        uint256 favId,
        address operator,
        bool approved
    ) external;


    function isApprovedForAll(
        uint256 favId,
        address account,
        address operator
    ) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 favId,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256 favId,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function uri(uint256 favId, uint256 tokenId) external view returns (string memory);
}
