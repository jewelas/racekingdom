// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./IRaceKingdom.sol";
import "./IRKVesting.sol";

contract RKStaking is Context, Ownable {
    using SafeMath for uint256;

    mapping (uint256 => address) internal _stakeholders;
    mapping (address => uint256) internal _stakeholderIndex;
    mapping(address => uint256[]) internal _stakesAmount;
    mapping(address => uint256[]) internal _stakesTime;
    mapping(address => uint256) internal _lastClaimedTime;
    uint256 internal _stakeholdersCount;


    

    IRaceKingdom _racekingdom;
    IRKVesting _rkvesting;


    constructor (address RaceKingdomAddr, address RKVestingAddr) {
        _racekingdom = IRaceKingdom(RaceKingdomAddr);
        _rkvesting = IRKVesting(RKVestingAddr);
    }

    function quarter () internal view returns(uint256) {
        return ((_rkvesting.Month().add(2)).div(3));
    }

    function getQuarter (uint256 time) internal view returns (uint256) {
        return ((_rkvesting.getMonth(time).add(2)).div(3));
    }

    function  isStakeholder(address addr) public view returns(bool) {
        if(_stakeholderIndex[addr] > 0) return (true);
        else return (false);
    }

    function addStakeholder (address holder) internal {
        require(!isStakeholder(holder), "Already exists in holders list.");
        _stakeholdersCount = _stakeholdersCount.add(1);
        _stakeholders[_stakeholdersCount] = holder;
        _stakeholderIndex[holder] = _stakeholdersCount;
    }

    function removeStakeholder(address holder) internal {
        require(isStakeholder(holder), "Not a stake holder address.");
        uint256 index = _stakeholderIndex[holder];
        address lastHolder = _stakeholders[_stakeholdersCount];
        delete _stakeholderIndex[holder];
        delete _stakeholders[index];
        delete _stakeholderIndex[lastHolder];
        delete _stakeholders[_stakeholdersCount];
        _stakeholders[index] = lastHolder;
        _stakeholderIndex[lastHolder] = index;
        _stakeholdersCount = _stakeholdersCount.sub(1);
    }

    function stakeOf (address holder) public view returns(uint256) {
        require(isStakeholder(holder), "Not a stake holder address.");
        uint256 stakes = 0;
        for (uint256 i = 0; i < _stakesAmount[holder].length; i++) {
            stakes = stakes.add(_stakesAmount[holder][i]);
        }
        return stakes;
    }

    function quarterStakeOf (address holder, uint256 quar) internal view returns(uint256) {
        require(isStakeholder(holder), "Not a stake holder address.");
        uint256 stakes = 0;
        for (uint256 i = 0; i < _stakesAmount[holder].length; i++) {
            if(getQuarter(_stakesTime[holder][i]) == quar) {
                stakes = stakes.add(_stakesAmount[holder][i]);
            }
        }
        return stakes;
    }

    function totalStakes() public view returns(uint256) {
        uint256 _totalStakes = 0;
        for (uint256 i=1; i <= _stakeholdersCount; i++) {
            _totalStakes = _totalStakes.add(stakeOf(_stakeholders[i]));
        }
        return _totalStakes;
    }

    function quarterTotalStaked(uint256 quar) internal view returns (uint256) {
        uint256 _quaterStakes = 0;
        for (uint256 i=1; i <= _stakeholdersCount; i++) {
            _quaterStakes = _quaterStakes.add(quarterStakeOf(_stakeholders[i], quar));
        }
        return _quaterStakes;
    }

    function getAPY (uint256 quar) internal view returns (uint256) {
        uint256 quarterStaked = quarterTotalStaked(quar);
        uint256 quarterVestingAmount = _rkvesting.quarterVestingAmount(quar.add(1));
        uint256 apy = quarterVestingAmount.mul(10000).div(quarterStaked);
        return apy;
    }

    function createStake(uint256 amount) public returns (bool) {
        require(_racekingdom.transferFrom(msg.sender, address(this), amount), "Transer Failed!");
        if(!isStakeholder(msg.sender)) addStakeholder(msg.sender);
        _stakesAmount[msg.sender].push(amount);
        _stakesTime[msg.sender].push(block.timestamp);
        return true;
    }

    function removableStake (address holder) public view returns (uint256) {
        require(isStakeholder(holder), "Not a stake holder address");
        uint256 stakes = 0;
        for (uint256 i = 0; i < _stakesAmount[holder].length; i++) {
            if (block.timestamp.sub(_stakesTime[holder][i]) >= 90 days) {
                stakes = stakes.add(_stakesAmount[holder][i]);
            }
        }
        return stakes;

    }

    function removeStake (uint256 amount) public {
        require(isStakeholder(msg.sender), "Not a stake holder address");
        require(removableStake(msg.sender) >= amount, "Removable amount not enough.");
        require(amount > 0, "Removing zero amount.");

        claim();

        for (uint256 i = _stakesAmount[msg.sender].length.sub(1); i >= 0; i--) {
            if(amount == 0) break;
            if (block.timestamp.sub(_stakesTime[msg.sender][i]) >= 90 days) {
                if(_stakesAmount[msg.sender][i] > amount) {
                    _stakesAmount[msg.sender][i] = _stakesAmount[msg.sender][i].sub(amount);
                    break;
                }else {
                    amount = amount.sub(_stakesAmount[msg.sender][i]);
                    for (uint256 index = i; index < _stakesAmount[msg.sender].length.sub(1); index++) {
                        _stakesAmount[msg.sender][index] = _stakesAmount[msg.sender][index.add(1)];
                        _stakesTime[msg.sender][index] = _stakesTime[msg.sender][index.add(1)];
                        _stakesAmount[msg.sender].pop();
                        _stakesTime[msg.sender].pop();
                    }
                }
            }
        }
        if(stakeOf(msg.sender) == 0) removeStakeholder(msg.sender);
        _racekingdom.transfer(msg.sender, amount);
    }

    function rewardsOf (address holder) public view returns(uint256) {
        require(isStakeholder(holder), "Not a stake holder address");
        uint256 rewards = 0;
        for (uint256 i = 0; i < _stakesAmount[holder].length; i++) {
            if(_lastClaimedTime[holder] > 0) {
                if (block.timestamp.sub(_stakesTime[holder][i]) >= 90 days && _lastClaimedTime[holder].sub(_stakesTime[holder][i]) < 90 days) {
                    rewards = rewards.add(_stakesAmount[holder][i].mul(getAPY(getQuarter(_stakesTime[holder][i]))).div(10000));
                }
            }else{
                if (block.timestamp.sub(_stakesTime[holder][i]) >= 90 days) {
                    rewards = rewards.add(_stakesAmount[holder][i].mul(getAPY(getQuarter(_stakesTime[holder][i]))).div(10000));
                }
            }
        }
        return rewards;
    }

    function totalRewards () public view returns(uint256) {
        uint256 _totalRewards = 0;
        for (uint256 i=1; i <= _stakeholdersCount; i++) {
            _totalRewards = _totalRewards.add(rewardsOf(_stakeholders[i]));
        }
        return _totalRewards;
    }

    function claim () public returns (bool) {
        uint256 reward = rewardsOf(msg.sender);
        if(reward > 0) {
            require(_racekingdom.transfer(msg.sender, reward), "Claim transer failed.");
            _lastClaimedTime[msg.sender] = block.timestamp;
            return true;
        }
        else return false;

    }

    function withdrawReward () public {
        removeStake(removableStake(msg.sender));
    }

}

