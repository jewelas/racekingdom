// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./IRaceKingdom.sol";
import "./IRKVesting.sol";

contract RKVesting is Context, Ownable {
    using SafeMath for uint256;

    mapping (uint256 => address) internal _stakeholders;
    mapping (address => uint256) internal _stakeholderIndex;
    mapping(address => uint256) internal _stakes;
    mapping(address => uint256) internal _rewards;
    uint256 _stakeholdersCount;


    

    IRaceKingdom _racekingdom;
    IRKVesting _rkvesting;


    constructor (address RaceKingdomAddr, address RKVestingAddr) {
        _racekingdom = IRaceKingdom(RaceKingdomAddr);
        _rkvesting = IRKVesting(RKVestingAddr);
    }

    function quarter () public view returns(uint256) {
        return ((_rkvesting.Month().add(2)).div(3));
    }

    function  isStakeholder(address addr) public view returns(bool) {
        if(_stakeholderIndex[addr] > 0) return (true);
        else return (false);
    }

    function addStakeholder (address holder) public {
        require(!isStakeholder(holder), "Already exists in holders list.");
        _stakeholdersCount = _stakeholdersCount.add(1);
        _stakeholders[_stakeholdersCount] = holder;
        _stakeholderIndex[holder] = _stakeholdersCount;
    }

    function removeStakeholder(address holder) public {
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
        return _stakes[holder];
    }

    function totalStakes() public view returns(uint256) {
        uint256 _totalStakes = 0;
        for (uint256 i=1; i <= _stakeholdersCount; i++) {
            _totalStakes = _totalStakes.add(_stakes[_stakeholders[i]]);
        }
        return _totalStakes;
    }

    function createStake(uint256 amount) public {
        require(_racekingdom.transferFrom(msg.sender, address(this), amount), "Transer Failed!");
        if(!isStakeholder(msg.sender)) addStakeholder(msg.sender);
        _stakes[msg.sender] = _stakes[msg.sender].add(amount);
    }

    function removeStake (uint256 amount) public {
        require(isStakeholder(msg.sender), "Not a stake holder address");
        _stakes[msg.sender] = _stakes[msg.sender].sub(amount);
        if(_stakes[msg.sender] == 0) removeStakeholder(msg.sender);
        _racekingdom.transfer(msg.sender, amount);
    }

    function rewardsOf (address holder) returns(uint256) {
        return _rewards[holder];
    }

    function totalRewards () public view returns(uint256) {
        uint256 _totalRewards = 0;
        for (uint256 i=1; i <= _stakeholdersCount; i++) {
            _totalRewards = _totalRewards.add(_rewards[_stakeholders[i]]);
        }
        return _totalRewards;
    }
    
}

