// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

abstract contract TransferLimiter is ERC20, Ownable {
    uint256 public constant TRANSFER_LIMIT_DENOMINATOR = 10000;

    uint256 public basePointsTransferLimit;

    constructor(uint256 _basePointsTranferLimit) {
        basePointsTransferLimit = _basePointsTranferLimit;
    }

    mapping(address => bool) public isTransferLimitWhitelisted;

    function addTransferLimit(address _address) external onlyOwner {
        isTransferLimitWhitelisted[_address] = true;
    }

    function removeTransferLimit(address _address) external onlyOwner {
        isTransferLimitWhitelisted[_address] = false;
    }

    function allowedAmount() public view returns (uint256) {
        return (totalSupply() * basePointsTransferLimit) / TRANSFER_LIMIT_DENOMINATOR;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        if (!isTransferLimitWhitelisted[from] && !isTransferLimitWhitelisted[to]) {
            require(amount <= allowedAmount(), "TransferLimiter: transfer amount exceeds limit");
        }
    }
}
