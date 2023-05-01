// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

abstract contract BlackLister is ERC20, Ownable {
    mapping(address => bool) public isBlacklisted;

    function addToBlacklist(address _address) external onlyOwner {
        isBlacklisted[_address] = true;
    }

    function removeFromBlacklist(address _address) external onlyOwner {
        isBlacklisted[_address] = false;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(!isBlacklisted[from] && !isBlacklisted[to], "Blacklister: blacklisted address.");
    }
}
