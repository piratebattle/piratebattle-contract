// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract iPirateBattleToken is ERC20, AccessControl {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    mapping(address => bool) public transferWhitelist;
    bool public allowTransfer;

    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        transferWhitelist[msg.sender] = true;
        _mint(msg.sender, 8000000000 * 10**18);
        allowTransfer = false;
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function setMinterRole(
        address account
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MINTER_ROLE, account);
    }

    function setWhiteListsUsers(
        address[] memory users
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 length = users.length;
        for (uint i = 0; i < length; i++) {
            require(users[i] != address(0), "invalid address");
            transferWhitelist[users[i]] = true;
        }
    }

    function revokeWhiteListsUsers(
        address[] memory users
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 length = users.length;
        for (uint i = 0; i < length; i++) {
            require(users[i] != address(0), "invalid address");
            transferWhitelist[users[i]] = false;
        }
    }

    function setAllowTransfer(
        bool _allowTransfer
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        allowTransfer = _allowTransfer;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(allowTransfer || transferWhitelist[from] || transferWhitelist[to]);
        super._beforeTokenTransfer(from, to, amount);
    }
}
