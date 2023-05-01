// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {TaxHandler} from "./TaxHandler.sol";

contract TaxHandledToken is TaxHandler {
    constructor(
        string memory _symbol,
        string memory _name,
        address _treasury,
        uint256 _transferFee,
        uint256 _buyFee,
        uint256 _sellFee
    ) TaxHandler(_symbol, _name, _treasury, _transferFee, _buyFee, _sellFee) {}
}
