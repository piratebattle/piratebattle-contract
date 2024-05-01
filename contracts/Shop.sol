// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract Shop is AccessControlEnumerable {

    IERC20 public token;

    event ItemBuySubmitted(address user, uint256 itemId, uint256 amount);
    event Withdrawal(address user, uint256 amount);

    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role"
        );
        _;
    }

    constructor(address _token) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        token = IERC20(_token);
    }

    function buyItem(uint256 itemId, uint256 amount) external {
        token.transferFrom(_msgSender(), address(this), amount);
        emit ItemBuySubmitted(_msgSender(), itemId, amount);
    }

    function shopVaultBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function setTokenAddress(address _token) external onlyAdmin {
        require(address(token) == _token, "token already set");
        token = IERC20(_token);
    }

    function withdraw(address receiver, uint256 amount) external onlyAdmin {
        require(receiver == address(0), "Receiver cannot be Zero address");
        token.transfer(receiver, amount);
        emit Withdrawal(receiver, amount);
    }
}
