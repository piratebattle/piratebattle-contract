// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingETH is Ownable {
    using SafeMath for uint256;
    address public token;
    uint256 public ETHStakeMIN;
    uint256 public ETHStakeMAX;
    uint256 public endtimeStake;
    uint256 public tokenRate;
    uint256 public ETHRate;
    uint256 public totalStaked;

    constructor(address _token, uint256 _endTimeStake) {
        endtimeStake = _endTimeStake;
        token = _token;
        totalStaked = 0;
        ETHStakeMIN = 0.06 ether;
        ETHStakeMAX = 0.3 ether;
        tokenRate = 3000 ether;
        ETHRate = 0.3 ether;
    }

    struct Staker {
        uint256 amountETHStaked;
        uint256 lastTimeClaimed;
    }

    mapping(address => Staker) public stakers;

    function setRate(uint256 _tokenRate, uint256 _ETHRate) public onlyOwner {
        tokenRate = _tokenRate;
        ETHRate = _ETHRate;
    }

    function setETHStakeMIN(uint256 _ethstakemin) public onlyOwner {
        ETHStakeMIN = _ethstakemin;
    }

    function setETHStakeMAX(uint256 _ethstakemax) public onlyOwner {
        ETHStakeMAX = _ethstakemax;
    }

    function setEndtimeStake(uint256 _endtimeStake) public onlyOwner {
        endtimeStake = _endtimeStake;
    }

    function getCurrentReward(address _address) public view returns (uint256) {
        uint256 toBlock = block.timestamp;
        if (toBlock > endtimeStake) {
            toBlock = endtimeStake;
        }
        uint256 stakedForBlocks = (toBlock - stakers[_address].lastTimeClaimed);
        uint256 totalRewards = (stakers[_address].amountETHStaked)
            .mul(stakedForBlocks)
            .mul(tokenRate)
            .div(ETHRate)
            .div(1 days);
        return totalRewards;
    }

    function stakeETH() public payable {
        uint256 _amount = msg.value;
        require(block.timestamp < endtimeStake, "Stake has expired");
        require(_amount > 0, "Amount must be greater than zero");
        require(
            stakers[msg.sender].amountETHStaked + _amount >= ETHStakeMIN &&
                stakers[msg.sender].amountETHStaked + _amount <= ETHStakeMAX,
            "STAKE: require amount must be in MIN and MAX!"
        );
        claimReward();
        stakers[msg.sender].amountETHStaked += _amount;
        totalStaked += _amount;
    }

    function claimReward() public {
        uint256 amountReward = getCurrentReward(msg.sender);
        stakers[msg.sender].lastTimeClaimed = block.timestamp;
        if (amountReward > 0) {
            IERC20(token).transfer(msg.sender, amountReward);
        }
    }

    function withdraw() public {
        require(
            block.timestamp > endtimeStake,
            "It's not time to withdraw yet"
        );
        require(stakers[msg.sender].amountETHStaked > 0, "user not staked");
        uint256 amount = stakers[msg.sender].amountETHStaked;
        stakers[msg.sender].amountETHStaked = 0;
        totalStaked -= amount;
        payable(address(msg.sender)).transfer(amount);
    }

    function getTotalStaked() public view returns (uint256) {
        return totalStaked;
    }
}
