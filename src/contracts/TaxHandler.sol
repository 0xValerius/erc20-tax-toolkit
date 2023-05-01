// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

abstract contract TaxHandler is ERC20, Ownable {
    // fees receiver
    address public treasury;

    // two decimal resolution
    uint256 public constant FEE_RATE_DENOMINATOR = 10000;

    uint256[3] public basisPointsFee;

    mapping(address => bool) public isFeeWhitelisted;
    mapping(address => bool) public isLiquidityPair;

    constructor(address _treasury, uint256 _transferFee, uint256 _buyFee, uint256 _sellFee) {
        treasury = _treasury;
        basisPointsFee[0] = _transferFee;
        basisPointsFee[1] = _buyFee;
        basisPointsFee[2] = _sellFee;
        isFeeWhitelisted[msg.sender] = true;
    }

    // set treasury address
    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    // set fee rate
    function setFees(uint256 _feeType, uint256 _basisPoint) external onlyOwner {
        basisPointsFee[_feeType] = _basisPoint;
    }

    // add address to whitelist
    function addWhitelist(address _address) external onlyOwner {
        isFeeWhitelisted[_address] = true;
    }

    // remove address from whitelist
    function removeWhitelist(address _address) external onlyOwner {
        isFeeWhitelisted[_address] = false;
    }

    // add liquidity pair
    function addLiquidityPair(address _address) external onlyOwner {
        isLiquidityPair[_address] = true;
    }

    // remove liquidity pair
    function removeLiquidityPair(address _address) external onlyOwner {
        isLiquidityPair[_address] = false;
    }

    function getFeeRate(address from, address to) public view returns (uint256) {
        // If either 'from' or 'to' is whitelisted, no tax is applied
        if (isFeeWhitelisted[from] || isFeeWhitelisted[to]) {
            return 0;
        }

        // If 'from' is a liquidity pair, apply buy tax (basisPointsFee[1])
        if (isLiquidityPair[from]) {
            return basisPointsFee[1];
        }

        // If 'to' is a liquidity pair, apply sell tax (basisPointsFee[2])
        if (isLiquidityPair[to]) {
            return basisPointsFee[2];
        }

        // If neither 'from' nor 'to' is a liquidity pair, apply transfer tax (basisPointsFee[0])
        return basisPointsFee[0];
    }

    // transfer with tax
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        uint256 feeRate = getFeeRate(from, to);
        if (feeRate > 0) {
            uint256 fee = (amount * feeRate) / FEE_RATE_DENOMINATOR;
            uint256 amountAfterFee = amount - fee;
            super._transfer(from, to, amountAfterFee);
            super._transfer(from, treasury, fee);
        } else {
            super._transfer(from, to, amount);
        }
    }
}
