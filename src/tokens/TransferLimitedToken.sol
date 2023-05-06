// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {TransferLimiter} from "../contracts/TransferLimiter.sol";

contract TransferLimitedToken is ERC20, TransferLimiter {
    constructor(string memory _name, string memory _symbol, uint256 _basePointsTranferLimit)
        ERC20(_name, _symbol)
        TransferLimiter(_basePointsTranferLimit)
    {}

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        virtual
        override(ERC20, TransferLimiter)
    {
        TransferLimiter._beforeTokenTransfer(from, to, amount);
    }
}
