// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract Sample {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}