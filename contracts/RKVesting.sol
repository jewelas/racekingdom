// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./IRaceKingdom.sol";

contract RKVesting is Context, Ownable {
    using SafeMath for uint256;

    mapping(uint256 => uint256[]) private _vestingPeriod;

    uint256 private constant _seedRound = 1;
    uint256 private constant _privateRound = 2;
    uint256 private constant _publicRound = 3;
    uint256 private constant _team = 4;
    uint256 private constant _advisors = 5;
    uint256 private constant _p2e = 6;
    uint256 private constant _staking = 7;
    uint256 private constant _ecosystem = 8;

    bool private _isTriggered;

    uint256 private _start;

    IRaceKingdom _racekingdom;


    constructor (address RaceKingdomAddr) {
        _racekingdom = IRaceKingdom(RaceKingdomAddr);
        _isTriggered = false;
    }

    function SeedRound () external view onlyOwner returns (uint256[] memory) {
        return(_vestingPeriod[_seedRound]);
    }

    function SetSeedRound (uint256[] memory vestingPeriod) public onlyOwner returns (bool) {
        _vestingPeriod[_seedRound] = vestingPeriod;
        return true;
    }

    function PrivateRound () external view onlyOwner returns ( uint256[] memory) {
        return( _vestingPeriod[_privateRound]);
    }

    function SetPrivateRound (uint256[] memory vestingPeriod) public onlyOwner returns (bool) {
        _vestingPeriod[_privateRound] = vestingPeriod;
        return true;
    }

    function PublicRound () external view onlyOwner returns (uint256[] memory) {
        return(_vestingPeriod[_publicRound]);
    }

    function SetPublicRound (uint256[] memory vestingPeriod) public onlyOwner returns (bool) {
        _vestingPeriod[_publicRound] = vestingPeriod;
        return true;
    }

    function Team () external view onlyOwner returns (uint256[] memory) {
        return(_vestingPeriod[_team]);
    }

    function SetTeam (uint256[] memory vestingPeriod) public onlyOwner returns (bool) {
        _vestingPeriod[_team] = vestingPeriod;
        return true;
    }

    function Advisors () external view onlyOwner returns (uint256[] memory) {
        return(_vestingPeriod[_advisors]);
    }

    function SetAdvisors (uint256[] memory vestingPeriod) public onlyOwner returns (bool) {
        _vestingPeriod[_advisors] = vestingPeriod;
        return true;
    }

    function P2E () external view onlyOwner returns (uint256[] memory) {
        return(_vestingPeriod[_p2e]);
    }

    function SetP2E (uint256[] memory vestingPeriod) public onlyOwner returns (bool) {
        _vestingPeriod[_p2e] = vestingPeriod;
        return true;
    }

    function Staking () external view onlyOwner returns (uint256[] memory) {
        return(_vestingPeriod[_staking]);
    }

    function SetStaking (uint256[] memory vestingPeriod) public onlyOwner returns (bool) {
        _vestingPeriod[_staking] = vestingPeriod;
        return true;
    }

    function Ecosystem () external view onlyOwner returns (uint256[] memory) {
        return(_vestingPeriod[_ecosystem]);
    }

    function SetEcosystem (uint256[] memory vestingPeriod) public onlyOwner returns (bool) {
        _vestingPeriod[_ecosystem] = vestingPeriod;
        return true;
    }
}

