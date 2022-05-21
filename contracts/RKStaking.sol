// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IRaceKingdom.sol";
import "./IRKVesting.sol";

contract RKStaking is Context, Ownable {
    using SafeMath for uint256;

    struct ClaimRecord {
        uint256 count;
        mapping(uint256 => uint256) time;
        mapping(uint256 => uint256) amount;
    }

    struct StakingRecord {
        uint256 count;
        mapping(uint256 => uint256) time;
        mapping(uint256 => uint256) amount;
        mapping(uint256 => uint256) lock;
    }

    mapping(uint256 => address) internal _stakeholders;
    mapping(address => uint256) internal _stakeholderIndex;
    mapping(address => StakingRecord) internal _stakes;
    mapping(address => uint256) internal _lastClaimedTime;
    mapping(address => ClaimRecord) internal _claimed;
    uint256 internal _stakeholdersCount;

    IRaceKingdom _racekingdom;
    IRKVesting _rkvesting;

    constructor(address RaceKingdomAddr, address RKVestingAddr) {
        _racekingdom = IRaceKingdom(RaceKingdomAddr);
        _rkvesting = IRKVesting(RKVestingAddr);
    }

    function _quarter() internal view returns (uint256) {
        return ((_rkvesting.Month().add(2)).div(3));
    }

    function _bimonth() internal view returns (uint256) {
        return ((_rkvesting.Month().add(1)).div(2));
    }

    function _getQuarter(uint256 time) internal view returns (uint256) {
        return ((_rkvesting.getMonth(time).add(2)).div(3));
    }

    function _getBimonth(uint256 time) internal view returns (uint256) {
        return ((_rkvesting.getMonth(time).add(1)).div(2));
    }

    function isStakeholder(address addr) public view returns (bool) {
        if (_stakeholderIndex[addr] > 0) return (true);
        else return (false);
    }

    function addStakeholder(address holder) internal {
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

    function stakeOf(address holder) public view returns (uint256) {
        require(isStakeholder(holder), "Not a stake holder address.");
        uint256 stakes = 0;
        for (uint256 i = 1; i <= _stakes[holder].count; i++) {
            stakes = stakes.add(_stakes[holder].amount[i]);
        }

        return stakes;
    }

    function quarterStakeOf(address holder, uint256 quarter)
        internal
        view
        returns (uint256)
    {
        require(isStakeholder(holder), "Not a stake holder address.");
        uint256 stakes = 0;
        for (uint256 i = 1; i <= _stakes[holder].count; i++) {
            if (_getQuarter(_stakes[holder].time[i]) == quarter) {
                stakes = stakes.add(_stakes[holder].amount[i]);
            }
        }
        return stakes;
    }

    function quarterStake90Of(address holder, uint256 quarter)
        internal
        view
        returns (uint256)
    {
        require(isStakeholder(holder), "Not a stake holder address.");
        uint256 stakes = 0;
        for (uint256 i = 1; i <= _stakes[holder].count; i++) {
            if (
                _getQuarter(_stakes[holder].time[i]) == quarter &&
                _stakes[holder].lock[i] == 90
            ) {
                stakes = stakes.add(_stakes[holder].amount[i]);
            }
        }
        return stakes;
    }

    function bimonthStake60Of(address holder, uint256 bimonth)
        internal
        view
        returns (uint256)
    {
        require(isStakeholder(holder), "Not a stake holder address.");
        uint256 stakes = 0;
        for (uint256 i = 1; i <= _stakes[holder].count; i++) {
            if (
                _getBimonth(_stakes[holder].time[i]) == bimonth &&
                _stakes[holder].lock[i] == 60
            ) {
                stakes = stakes.add(_stakes[holder].amount[i]);
            }
        }
        return stakes;
    }

    function monthStake30Of(address holder, uint256 month)
        internal
        view
        returns (uint256)
    {
        require(isStakeholder(holder), "Not a stake holder address.");
        uint256 stakes = 0;
        for (uint256 i = 1; i <= _stakes[holder].count; i++) {
            if (
                _rkvesting.getMonth(_stakes[holder].time[i]) == month &&
                _stakes[holder].lock[i] == 30
            ) {
                stakes = stakes.add(_stakes[holder].amount[i]);
            }
        }
        return stakes;
    }


    function totalStakes() public view returns (uint256) {
        uint256 _totalStakes = 0;
        for (uint256 i = 1; i <= _stakeholdersCount; i++) {
            _totalStakes = _totalStakes.add(stakeOf(_stakeholders[i]));
        }
        return _totalStakes;
    }

    function quarterTotalStaked(uint256 quarter)
        internal
        view
        returns (uint256)
    {
        uint256 _quaterStakes = 0;
        for (uint256 i = 1; i <= _stakeholdersCount; i++) {
            _quaterStakes = _quaterStakes.add(
                quarterStakeOf(_stakeholders[i], quarter)
            );
        }
        return _quaterStakes;
    }

    function quarterTotalStaked90(uint256 quarter)
        internal
        view
        returns (uint256)
    {
        uint256 _quaterStakes = 0;
        for (uint256 i = 1; i <= _stakeholdersCount; i++) {
            _quaterStakes = _quaterStakes.add(
                quarterStake90Of(_stakeholders[i], quarter)
            );
        }
        return _quaterStakes;
    }

    function bimonthTotalStaked60(uint256 bimonth)
        internal
        view
        returns (uint256)
    {
        uint256 _bimonthStakes = 0;
        for (uint256 i = 1; i <= _stakeholdersCount; i++) {
            _bimonthStakes = _bimonthStakes.add(
                bimonthStake60Of(_stakeholders[i], bimonth)
            );
        }
        return _bimonthStakes;
    }

    function monthTotalStaked30(uint256 month)
        internal
        view
        returns (uint256)
    {
        uint256 _monthStakes = 0;
        for (uint256 i = 1; i <= _stakeholdersCount; i++) {
            _monthStakes = _monthStakes.add(
                monthStake30Of(_stakeholders[i], month)
            );
        }
        return _monthStakes;
    }

    function getAPY(uint256 time, uint256 lock) public view returns (uint256) {
        if (lock == 90) {
            uint256 quarter = _getQuarter(time);
            uint256 quarterStaked = quarterTotalStaked90(quarter);
            uint256 minStaked = _rkvesting
                .tillMonthTotalVestingAmount(quarter.mul(3))
                .mul(5)
                .div(100);
            if (quarterStaked < minStaked) quarterStaked = minStaked;
            uint256 quarterVestingAmountOfStakingReward = _rkvesting.quarterVestingAmountOfStakingReward90(quarter.add(1));
            uint256 apy = quarterVestingAmountOfStakingReward.mul(10000).div(
                quarterStaked
            );
            return apy;
        }
        else if (lock == 60) {
            uint256 bimonth = _getBimonth(time);
            uint256 bimonthStaked = bimonthTotalStaked60(bimonth);
            uint256 minStaked = _rkvesting
                .tillMonthTotalVestingAmount(bimonth.mul(2))
                .mul(5)
                .div(100);
            if (bimonthStaked < minStaked) bimonthStaked = minStaked;
            uint256 bimonthVestingAmountOfStakingReward = _rkvesting.bimonthVestingAmountOfStakingReward60(bimonth.add(1));
            uint256 apy = bimonthVestingAmountOfStakingReward.mul(10000).div(
                bimonthStaked
            );  
            return apy;
        }
        else if (lock == 30) {
            uint256 month = _rkvesting.getMonth(time);
            uint256 monthStaked = monthTotalStaked30(month);
            uint256 minStaked = _rkvesting
                .tillMonthTotalVestingAmount(month)
                .mul(5)
                .div(100);
            if (monthStaked < minStaked) monthStaked = minStaked;
            uint256 monthVestingAmountOfStakingReward = _rkvesting.monthVestingAmountOfStakingReward30(month.add(1));
            uint256 apy = monthVestingAmountOfStakingReward.mul(10000).div(
                monthStaked
            );
            return apy;
        }
        else{
            return 0;
        }
    }

    function createStake(uint256 amount, uint256 lock) public returns (bool) {
        require(
            _racekingdom.transferFrom(msg.sender, address(this), amount),
            "transfer Failed!"
        );
        if (!isStakeholder(msg.sender)) addStakeholder(msg.sender);
        _stakes[msg.sender].count = _stakes[msg.sender].count.add(1);
        _stakes[msg.sender].time[_stakes[msg.sender].count] = block.timestamp;
        _stakes[msg.sender].amount[_stakes[msg.sender].count] = amount;
        _stakes[msg.sender].lock[_stakes[msg.sender].count] = lock;
        return true;
    }

    function removableStake(address holder) public view returns (uint256) {
        require(isStakeholder(holder), "Not a stake holder address");
        uint256 stakes = 0;
        for (uint256 i = 1; i <= _stakes[holder].count; i++) {
            if (block.timestamp.sub(_stakes[holder].time[i]) >= _stakes[holder].lock[i].mul(1 days)) {
                stakes = stakes.add(_stakes[holder].amount[i]);
            }
        }
        return stakes;
    }

    function removeStake(uint256 amount) public {
        require(isStakeholder(msg.sender), "Not a stake holder address");
        require(amount > 0, "Removing zero amount.");
        require(amount <= stakeOf(msg.sender), "Removing Exeeded Amount");
        uint256 usualAmount;
        uint256 earlyAmount;
        uint256 _usualAmount;
        uint256 _earlyAmount;
        if (amount > removableStake(msg.sender)) {
            usualAmount = removableStake(msg.sender);
            earlyAmount = amount.sub(removableStake(msg.sender));
            _earlyAmount = earlyAmount;
        } else {
            usualAmount = amount;
        }
        _usualAmount = usualAmount;

        claimReward();

        for (uint256 i = _stakes[msg.sender].count; i > 0; i--) {
            if (_usualAmount == 0 && _earlyAmount == 0) break;
            if (block.timestamp.sub(_stakes[msg.sender].time[i]) >= _stakes[msg.sender].lock[i].mul(1 days)) {
                if (_usualAmount > 0) {
                    if (_stakes[msg.sender].amount[i] > _usualAmount) {
                        _stakes[msg.sender].amount[i] = _stakes[msg.sender]
                            .amount[i]
                            .sub(_usualAmount);
                        _usualAmount = 0;
                    } else {
                        _usualAmount = _usualAmount.sub(
                            _stakes[msg.sender].amount[i]
                        );
                        _stakes[msg.sender].amount[i] = _stakes[msg.sender]
                            .amount[_stakes[msg.sender].count];
                        _stakes[msg.sender].time[i] = _stakes[msg.sender].time[
                            _stakes[msg.sender].count
                        ];
                        delete _stakes[msg.sender].amount[
                            _stakes[msg.sender].count
                        ];
                        delete _stakes[msg.sender].time[
                            _stakes[msg.sender].count
                        ];
                        _stakes[msg.sender].count = _stakes[msg.sender]
                            .count
                            .sub(1);
                    }
                }
            } else {
                if (_earlyAmount > 0) {
                    if (_stakes[msg.sender].amount[i] > _earlyAmount) {
                        _stakes[msg.sender].amount[i] = _stakes[msg.sender]
                            .amount[i]
                            .sub(_earlyAmount);
                        _earlyAmount = 0;
                    } else {
                        _earlyAmount = _earlyAmount.sub(
                            _stakes[msg.sender].amount[i]
                        );
                        _stakes[msg.sender].amount[i] = _stakes[msg.sender]
                            .amount[_stakes[msg.sender].count];
                        _stakes[msg.sender].time[i] = _stakes[msg.sender].time[
                            _stakes[msg.sender].count
                        ];
                        delete _stakes[msg.sender].amount[
                            _stakes[msg.sender].count
                        ];
                        delete _stakes[msg.sender].time[
                            _stakes[msg.sender].count
                        ];
                        _stakes[msg.sender].count = _stakes[msg.sender]
                            .count
                            .sub(1);
                    }
                }
            }
        }
        if (stakeOf(msg.sender) == 0) removeStakeholder(msg.sender);
        _claimed[msg.sender].count = _claimed[msg.sender].count.add(1);
        _claimed[msg.sender].time[_claimed[msg.sender].count] = block
            .timestamp
            .sub(2 days);
        _claimed[msg.sender].amount[_claimed[msg.sender].count] = usualAmount;

        if (earlyAmount > 0) {
            _claimed[msg.sender].count = _claimed[msg.sender].count.add(1);
            _claimed[msg.sender].time[_claimed[msg.sender].count] = block
                .timestamp;
            _claimed[msg.sender].amount[
                _claimed[msg.sender].count
            ] = earlyAmount;
        }
    }

    function rewardsOf(address holder) public view returns (uint256) {
        require(isStakeholder(holder), "Not a stake holder address");
        uint256 rewards = 0;
        for (uint256 i = 1; i <= _stakes[holder].count; i++) {
            if (_lastClaimedTime[holder] > _stakes[holder].time[i]) {
                if (
                    block.timestamp.sub(_stakes[holder].time[i]) >= _stakes[holder].lock[i].mul(1 days) &&
                    _lastClaimedTime[holder].sub(_stakes[holder].time[i]) <
                    _stakes[holder].lock[i].mul(1 days)
                ) {
                    rewards = rewards.add(
                        _stakes[holder]
                            .amount[i]
                            .mul(getAPY(_stakes[holder].time[i], _stakes[holder].lock[i]))
                            .div(10000)
                    );
                }
            } else {
                if (block.timestamp.sub(_stakes[holder].time[i]) >= _stakes[holder].lock[i].mul(1 days)) {
                    rewards = rewards.add(
                        _stakes[holder]
                            .amount[i]
                            .mul(getAPY(_stakes[holder].time[i], _stakes[holder].lock[i]))
                            .div(10000)
                    );
                }
            }
        }
        return rewards;
    }

    function totalRewards() public view returns (uint256) {
        uint256 _totalRewards = 0;
        for (uint256 i = 1; i <= _stakeholdersCount; i++) {
            _totalRewards = _totalRewards.add(rewardsOf(_stakeholders[i]));
        }
        return _totalRewards;
    }

    function claimReward() public returns (bool) {
        uint256 reward = rewardsOf(msg.sender);
        if (reward > 0) {
            _claimed[msg.sender].count = _claimed[msg.sender].count.add(1);
            _claimed[msg.sender].time[_claimed[msg.sender].count] = block
                .timestamp
                .sub(2 days);
            _claimed[msg.sender].amount[_claimed[msg.sender].count] = reward;
            _lastClaimedTime[msg.sender] = block.timestamp;
            return true;
        } else return false;
    }

    function claim() public {
        removeStake(removableStake(msg.sender));
    }

    function withdrawClaimed() public returns (bool) {
        uint256 withdrawable;
        for (uint256 i = _claimed[msg.sender].count; i >= 1; i--) {
            if (block.timestamp.sub(_claimed[msg.sender].time[i]) >= 3 days) {
                withdrawable = withdrawable.add(_claimed[msg.sender].amount[i]);
                _claimed[msg.sender].time[i] = _claimed[msg.sender].time[
                    _claimed[msg.sender].count
                ];
                _claimed[msg.sender].amount[i] = _claimed[msg.sender].amount[
                    _claimed[msg.sender].count
                ];
                delete _claimed[msg.sender].time[_claimed[msg.sender].count];
                delete _claimed[msg.sender].amount[_claimed[msg.sender].count];
                _claimed[msg.sender].count = _claimed[msg.sender].count.sub(1);
            }
        }
        if (withdrawable > 0) {
            _racekingdom.transfer(msg.sender, withdrawable);
        }
        return true;
    }
}
