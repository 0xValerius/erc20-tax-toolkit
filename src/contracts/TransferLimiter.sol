// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

abstract contract TransferLimiter is ERC20, Ownable {
    // two decimal resolution
    uint256 public constant TRANSFER_LIMIT_DENOMINATOR = 10000;

    uint256 public basePointsTransferLimit;

    constructor(uint256 _basePointsTranferLimit) {
        basePointsTransferLimit = _basePointsTranferLimit;
    }

    mapping(address => bool) public isTransferWhitelisted;

    function addTransferLimit(address _address) external onlyOwner {
        isTransferWhitelisted[_address] = true;
    }

    function removeTransferLimit(address _address) external onlyOwner {
        isTransferWhitelisted[_address] = false;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        if (!isTransferWhitelisted[from] && !isTransferWhitelisted[to]) {
            uint256 balance = balanceOf(from);
            require(
                amount <= (totalSupply * basePointsTransferLimit) / TRANSFER_LIMIT_DENOMINATOR,
                "TransferLimiter: transfer amount exceeds limit"
            );
        }
    }
}
