// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

abstract contract BlackLister is ERC20, Ownable {
    mapping(address => bool) public isBlacklisted;

    function blacklist(address _address, bool _status) external onlyOwner {
        isBlacklisted[_address] = _status;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!isBlacklisted[from] && !isBlacklisted[to], "Blacklister: blacklisted address.");
    }
}
