// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./IRaceKingdom.sol";

contract RKVesting is Context, Ownable {
    using SafeMath for uint256;

    mapping (uint256 => address) internal _stakeholders;
    mapping (address => uint256) internal _stakeholderIndex;
    mapping(address => uint256) internal _stakes;
    uint256 _stakeholdersCount;


    

    IRaceKingdom _racekingdom;


    constructor (address RaceKingdomAddr) {
        _racekingdom = IRaceKingdom(RaceKingdomAddr);
    }

    function  isStakeholder(address addr) public view returns(bool, uint256) {
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
    
}

