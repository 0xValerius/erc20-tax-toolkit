// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

abstract contract BalanceLimiter is ERC20, Ownable {
    uint256 public constant BALANCE_LIMIT_DENOMINATOR = 10000;
    uint256 public basePointsBalanceLimit;
    mapping(address => bool) public isBalanceLimitWhitelisted;

    constructor(uint256 _basePointsBalanceLimit) {
        basePointsBalanceLimit = _basePointsBalanceLimit;
        isBalanceLimitWhitelisted[msg.sender] = true;
    }

    function balanceLimitWL(address _address, bool _status) external onlyOwner {
        isBalanceLimitWhitelisted[_address] = _status;
    }

    function allowedMaxBalance() public view returns (uint256) {
        return (totalSupply() * basePointsBalanceLimit) / BALANCE_LIMIT_DENOMINATOR;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        if (!isBalanceLimitWhitelisted[from] && !isBalanceLimitWhitelisted[to]) {
            require(amount <= allowedMaxBalance(), "BalanceLimiter: balance amount exceeds limit");
        }
    }
}
