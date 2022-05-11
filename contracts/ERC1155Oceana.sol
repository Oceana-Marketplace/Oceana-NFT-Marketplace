// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC1155Oceana.sol";

import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";


abstract contract ERC1155Oceana is Context, ERC165, IERC1155Oceana {
    using Address for address;

    // Mapping from favId => token ID to account balances
    mapping(uint256 => mapping(uint256 => mapping(address => uint256)))
        private _balances;

    // Mapping from favId => account to operator approvals
    mapping(uint256 => mapping(address => mapping(address => bool)))
        private _operatorApprovals;

    mapping(uint256 => mapping(uint256 => string)) _uri;

    constructor() {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155Oceana).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256 favId, uint256 tokenId)
        public
        view
        override
        virtual
        returns (string memory)
    {
        return _uri[favId][tokenId];
    }

    function _setURI(uint256 favId, uint256 tokenId, string memory newUri) internal virtual{
        _uri[favId][tokenId] = newUri;
        emit URI(favId, tokenId, newUri);
    }

    function balanceOf(
        uint256 favId,
        address account,
        uint256 id
    ) public view virtual override returns (uint256) {
        require(
            account != address(0),
            "ERC1155: balance query for the zero address"
        );
        return _balances[favId][id][account];
    }

    function balanceOfBatch(
        uint256 favId,
        address[] memory accounts,
        uint256[] memory ids
    ) public view virtual override returns (uint256[] memory) {
        require(
            accounts.length == ids.length,
            "ERC1155: accounts and ids length mismatch"
        );

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(favId, accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(
        uint256 favId,
        address operator,
        bool approved
    ) public virtual override {
        _setApprovalForAll(favId, _msgSender(), operator, approved);
    }

    function isApprovedForAll(
        uint256 favId,
        address account,
        address operator
    ) public view virtual override returns (bool) {
        return _operatorApprovals[favId][account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 favId,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(favId, from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, favId, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256 favId,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(favId, from, _msgSender()),
            "ERC1155: transfer caller is not owner"
        );

        _safeBatchTransferFrom(from, to, favId, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 favId,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, favId, ids, amounts, data);

        uint256 fromBalance = _balances[favId][id][from];
        require(
            fromBalance >= amount,
            "ERC1155: insufficient balance for transfer"
        );
        unchecked {
            _balances[favId][id][from] = fromBalance - amount;
        }
        _balances[favId][id][to] += amount;

        emit TransferSingle(operator, from, to, favId, id, amount);

        _afterTokenTransfer(operator, from, to, favId, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256 favId,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, favId, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[favId][id][from];
            require(
                fromBalance >= amount,
                "ERC1155: insufficient balance for transfer"
            );
            unchecked {
                _balances[favId][id][from] = fromBalance - amount;
            }
            _balances[favId][id][to] += amount;
        }

        emit TransferBatch(operator, from, to, favId, ids, amounts);

        _afterTokenTransfer(operator, from, to, favId, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            from,
            to,
            ids,
            amounts,
            data
        );
    }

    function _mint(
        address to,
        uint256 favId,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(
            operator,
            address(0),
            to,
            favId,
            ids,
            amounts,
            data
        );

        _balances[favId][id][to] += amount;
        emit TransferSingle(operator, address(0), to, favId, id, amount);

        _afterTokenTransfer(
            operator,
            address(0),
            to,
            favId,
            ids,
            amounts,
            data
        );

        _doSafeTransferAcceptanceCheck(
            operator,
            address(0),
            to,
            id,
            amount,
            data
        );
    }

    function _mintBatch(
        address to,
        uint256 favId,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            address(0),
            to,
            favId,
            ids,
            amounts,
            data
        );

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[favId][ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, favId, ids, amounts);

        _afterTokenTransfer(
            operator,
            address(0),
            to,
            favId,
            ids,
            amounts,
            data
        );

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            address(0),
            to,
            ids,
            amounts,
            data
        );
    }

    function _burn(
        address from,
        uint256 favId,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(
            operator,
            from,
            address(0),
            favId,
            ids,
            amounts,
            ""
        );

        uint256 fromBalance = _balances[favId][id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[favId][id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), favId, id, amount);

        _afterTokenTransfer(
            operator,
            from,
            address(0),
            favId,
            ids,
            amounts,
            ""
        );
    }

    function _burnBatch(
        address from,
        uint256 favId,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            from,
            address(0),
            favId,
            ids,
            amounts,
            ""
        );

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[favId][id][from];
            require(
                fromBalance >= amount,
                "ERC1155: burn amount exceeds balance"
            );
            unchecked {
                _balances[favId][id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), favId, ids, amounts);

        _afterTokenTransfer(
            operator,
            from,
            address(0),
            favId,
            ids,
            amounts,
            ""
        );
    }

    function _setApprovalForAll(
        uint256 favId,
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[favId][owner][operator] = approved;
        emit ApprovalForAll(favId, owner, operator, approved);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256 favId,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256 favId,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    amount,
                    data
                )
            returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155BatchReceived(
                    operator,
                    from,
                    ids,
                    amounts,
                    data
                )
            returns (bytes4 response) {
                if (
                    response != IERC1155Receiver.onERC1155BatchReceived.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element)
        private
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}
