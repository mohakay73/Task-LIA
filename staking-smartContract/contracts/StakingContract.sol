// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public stakingToken;
    IERC20 public rewardToken;
    uint256 public rewardRate; // Reward rate per token per second
    uint256 public totalStaked;
    
    struct UserInfo {
        uint256 stakedAmount;
        uint256 rewardDebt;
        uint256 lastUpdated;
    }

    mapping(address => UserInfo) public userInfo;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardRateUpdated(uint256 newRate);

    constructor(IERC20 _stakingToken, IERC20 _rewardToken, uint256 _rewardRate) Ownable(msg.sender) {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
        rewardRate = _rewardRate;
    }

    modifier updateReward(address account) {
        if (account != address(0)) {
            UserInfo storage user = userInfo[account];
            uint256 reward = pendingReward(account);
            user.rewardDebt = user.rewardDebt + reward;
            user.lastUpdated = block.timestamp;
        }
        _;
    }

    function pendingReward(address account) public view returns (uint256) {
        UserInfo storage user = userInfo[account];
        return (block.timestamp - user.lastUpdated) * user.stakedAmount * rewardRate;
    }

    function stake(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        UserInfo storage user = userInfo[msg.sender];
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        user.stakedAmount += amount;
        totalStaked += amount;
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        UserInfo storage user = userInfo[msg.sender];
        require(user.stakedAmount >= amount, "Withdraw amount exceeds balance");
        user.stakedAmount -= amount;
        totalStaked -= amount;
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() external updateReward(msg.sender) {
        UserInfo storage user = userInfo[msg.sender];
        uint256 reward = user.rewardDebt;
        require(reward > 0, "No rewards to claim");
        user.rewardDebt = 0;
        rewardToken.safeTransfer(msg.sender, reward);
        emit RewardPaid(msg.sender, reward);
    }

    function updateRewardRate(uint256 newRate) external onlyOwner {
        rewardRate = newRate;
        emit RewardRateUpdated(newRate);
    }
}
