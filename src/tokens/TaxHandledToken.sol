// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {TaxHandler} from "../contracts/TaxHandler.sol";

contract TaxHandledToken is ERC20, TaxHandler {
    constructor(
        string memory _name,
        string memory _symbol,
        address _treasury,
        uint256 _transferFee,
        uint256 _buyFee,
        uint256 _sellFee
    ) ERC20(_name, _symbol) TaxHandler(_treasury, _transferFee, _buyFee, _sellFee) {}

    function _transfer(address from, address to, uint256 amount) internal virtual override(ERC20, TaxHandler) {
        TaxHandler._transfer(from, to, amount);
    }
}
