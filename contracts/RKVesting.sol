// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./IRaceKingdom.sol";

contract RKVesting is Context, Ownable {
    using SafeMath for uint256;
    
    IRaceKingdom _racekingdom;


    constructor (address RaceKingdomAddr) {
        _racekingdom = IRaceKingdom(RaceKingdomAddr);
    }
}

