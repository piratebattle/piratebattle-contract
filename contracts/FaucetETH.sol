//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
contract FaucetETH is Context, AccessControlEnumerable, Initializable {

    address public signerAddress;
    bool public paused;
    uint256 public faucetAmount;

    mapping(address => bool) public faucetHistory;

    function initialize(
        address _signerAddress,
        uint256 _faucetAmount
    ) public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        signerAddress = _signerAddress;
        faucetAmount = _faucetAmount;
    }

    function faucetETH(address payable toAddress) public {
        require(address(this).balance >= faucetAmount,"Not Enough ETH");
        require(!paused, "Faucet Was Paused");
        require(_msgSender() == signerAddress, "Invalid Signer");
        require(!faucetHistory[toAddress], "Already faucet");

        faucetHistory[toAddress] = true;
        //Transfer
        toAddress.call{value: faucetAmount}("");
    }

    function setPause(bool _bool) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role"
        );
        paused = _bool;
    }

    function setSigner(address _signerAddress) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role"
        );
        signerAddress = _signerAddress;
    }

    function setFaucetAmount(uint256 _faucetAmount) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role"
        );
        faucetAmount = _faucetAmount;
    }

    receive() external payable {}

    fallback() external payable {}
}