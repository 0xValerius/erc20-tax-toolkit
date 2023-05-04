// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {BalanceLimiter} from "./contracts/BalanceLimiter.sol";
import {TransferLimiter} from "./contracts/TransferLimiter.sol";

contract BalanceTransferLimitedToken is ERC20, BalanceLimiter, TransferLimiter {
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _basePointsBalanceLimit,
        uint256 _basePointsTransferLimit
    ) ERC20(_name, _symbol) BalanceLimiter(_basePointsBalanceLimit) TransferLimiter(_basePointsTransferLimit) {}

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        virtual
        override(ERC20, BalanceLimiter, TransferLimiter)
    {
        BalanceLimiter._beforeTokenTransfer(from, to, amount);
        TransferLimiter._beforeTokenTransfer(from, to, amount);
    }
}
