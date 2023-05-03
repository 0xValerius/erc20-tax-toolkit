// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {BalanceLimiter} from "./contracts/BalanceLimiter.sol";

contract BalanceLimitedToken is ERC20, BalanceLimiter {
    constructor(string memory _name, string memory _symbol, uint256 _basePointsBalanceLimit)
        ERC20(_name, _symbol)
        BalanceLimiter(_basePointsBalanceLimit)
    {}

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        virtual
        override(ERC20, BalanceLimiter)
    {
        BalanceLimiter._beforeTokenTransfer(from, to, amount);
    }
}
