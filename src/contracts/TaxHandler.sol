// SPDX-License-Identifier: MIT

/*

      .oooo.               oooooo     oooo           oooo                      o8o                       
     d8P'`Y8b               `888.     .8'            `888                      `"'                       
    888    888 oooo    ooo   `888.   .8'    .oooo.    888   .ooooo.  oooo d8b oooo  oooo  oooo   .oooo.o 
    888    888  `88b..8P'     `888. .8'    `P  )88b   888  d88' `88b `888""8P `888  `888  `888  d88(  "8 
    888    888    Y888'        `888.8'      .oP"888   888  888ooo888  888      888   888   888  `"Y88b.  
    `88b  d88'  .o8"'88b        `888'      d8(  888   888  888    .o  888      888   888   888  o.  )88b 
     `Y8bd8P'  o88'   888o       `8'       `Y888""8o o888o `Y8bod8P' d888b    o888o  `V88V"V8P' 8""888P' 

*/

pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

/**
 * @title TaxHandler
 * @author 0xValerius
 * @notice The TaxHandler contract is an abstract contract that extends ERC20 and Ownable.
 * It provides functionality to apply taxes on token transfers, buys, and sells. Different tax rates
 * can be set for each type of transaction. Addresses can be whitelisted to be exempt from taxes.
 * Liquidity pairs can be specified to apply buy and sell taxes correctly.
 *
 * Note: Contract should be used as a parent contract for custom ERC20 tokens that require
 * tax handling functionality.
 */
abstract contract TaxHandler is ERC20, Ownable {
    address public treasury;

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

    /**
     * @notice Sets the treasury address.
     * @param _treasury The new treasury address.
     */
    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    /**
     * @notice Sets the fee rate for a specific fee type.
     * @param _feeType The index of the fee type to update (0: transfer, 1: buy, 2: sell).
     * @param _basisPoint The new basis point value for the fee type.
     */
    function setFees(uint256 _feeType, uint256 _basisPoint) external onlyOwner {
        basisPointsFee[_feeType] = _basisPoint;
    }

    /**
     * @notice Adds or removes an address from the fee whitelist.
     * @param _address The address to update the whitelist status.
     * @param _status The new whitelist status (true: whitelisted, false: not whitelisted).
     */
    function feeWL(address _address, bool _status) external onlyOwner {
        isFeeWhitelisted[_address] = _status;
    }

    /**
     * @notice Adds or removes an address from the liquidity pair list.
     * @param _address The address to update the liquidity pair status.
     * @param _status The new liquidity pair status (true: liquidity pair, false: not liquidity pair).
     */
    function liquidityPairList(address _address, bool _status) external onlyOwner {
        isLiquidityPair[_address] = _status;
    }

    /**
     * @notice Returns the fee rate for a specific transaction.
     * @param from The sender address.
     * @param to The recipient address.
     * @return The fee rate for the transaction.
     */
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

    /**
     * @notice Overrides the _transfer function of the ERC20 contract to apply taxes.
     * @param from The sender address.
     * @param to The recipient address.
     * @param amount The amount to be transferred.
     */
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
