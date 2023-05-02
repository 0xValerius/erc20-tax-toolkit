// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {BlackLister} from "./contracts/BlackLister.sol";

contract BlackListerToken is ERC20, BlackLister {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        virtual
        override(ERC20, BlackLister)
    {
        BlackLister._beforeTokenTransfer(from, to, amount);
    }
}
