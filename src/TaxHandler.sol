// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

abstract contract TaxHandler is ERC20, Ownable {
    address public treasury;
    uint256 public constant FEE_RATE_DENOMINATOR = 10000;

    uint256[3] public basisPointsFee;
    mapping(address => bool) public isTaxWhitelisted;
    mapping(address => bool) public isLiquidityPair;

    constructor(
        string memory _name,
        string memory _symbol,
        address _treasury,
        uint256 _transferFee,
        uint256 _buyFee,
        uint256 _sellFee
    ) ERC20(_name, _symbol) {
        treasury = _treasury;
        basisPointsFee[0] = _transferFee;
        basisPointsFee[1] = _buyFee;
        basisPointsFee[2] = _sellFee;
        isTaxWhitelisted[msg.sender] = true;
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
        isTaxWhitelisted[_address] = true;
    }

    // remove address from whitelist
    function removeWhitelist(address _address) external onlyOwner {
        isTaxWhitelisted[_address] = false;
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
        if (!isTaxWhitelisted[from] && !isTaxWhitelisted[to]) {
            return basisPointsFee[0];
        } else {
            return 0;
        }
    }

    // transfer with tax
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        // if either sender or receiver is not whitelisted, apply tax
        if (!isTaxWhitelisted[from] && !isTaxWhitelisted[to]) {
            uint256 fee = (amount * basisPointsFee[0]) / FEE_RATE_DENOMINATOR;
            uint256 amountAfterFee = amount - fee;
            super._transfer(from, to, amountAfterFee);
            super._transfer(from, treasury, fee);
        } else {
            super._transfer(from, to, amount);
        }
    }
}
