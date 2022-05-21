// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRKVesting {
    function  Month () external view returns(uint256);

    function getMonth (uint256 time) external view returns (uint256);

    function quarterVestingAmount (uint256 quarter) external view returns (uint256);

    function quarterVestingAmountOfStakingReward (uint256 quarter) external view returns (uint256);

    function quarterTotalVestingAmount (uint256 quarter) external view returns (uint256);

    function tillMonthTotalVestingAmount (uint256 month) external view returns (uint256);

    function quarterVestingAmountOfStakingReward90 (uint256 quarter) external view returns (uint256);

    function bimonthVestingAmountOfStakingReward60 (uint256 bimonth) external view returns (uint256);

    function monthVestingAmountOfStakingReward30 (uint256 month) external view returns (uint256);
}