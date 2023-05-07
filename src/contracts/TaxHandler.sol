// SPDX-License-Identifier: MIT

/*

      .oooo.               oooooo     oooo           oooo                      o8o                       
     d8P'`Y8b               `888.     .8'            `888                      `"'                       
    888    888 oooo    ooo   `888.   .8'    .oooo.    888   .ooooo.  oooo d8b oooo  oooo  oooo   .oooo.o 
    888    888  `88b..8P'     `888. .8'    `P  )88b   888  d88' `88b `888""8P `888  `888  `888  d88(  "8 
    888    888    Y888'        `888.8'      .oP"888   888  888ooo888  888      888   888   888  `"Y88b.  
    `88b  d88'  .o8"'88b        `888'      d8(  888   888  888    .o  888      888   888   888  o.  )88b 
     `Y8bd8P'  o88'   888o       `8'       `Y888""8o o888o `Y8bod8P' d888b    o888o  `V88V"V8P' 8""888P' */

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
    /**
     * @notice OverMaxBasisPoints custom error.
     */
    error OverMaxBasisPoints();

    /**
     * @notice Token configuration struct.
     * @dev Struct packed into a slot, 28 bytes total.
     *      Basis point fees fit uint16, max is 10_000.
     * @custom:treasury Treasury address.
     * @custom:transferFeesBPs Transfer fees basis points.
     * @custom:buyFeesBPs Buy fees basis points.
     * @custom:sellFeesBPs Sell fees basis points.
     */
    struct TokenConfiguration {
        address treasury;
        uint16 transferFeesBPs;
        uint16 buyFeesBPs;
        uint16 sellFeesBPs;
    }

    /**
     * @notice Address configuration struct.
     * @dev Struct packed into a slot, 2 bytes total.
     * @custom:whitelisted Is address whitelisted.
     * @custom:liquidityPair Is address liquidity pair.
     */
    struct AddressConfiguration {
        bool whitelisted;
        bool liquidityPair;
    }

    /**
     * @notice Token configuration.
     */
    TokenConfiguration internal tokenConfiguration;

    /**
     * @notice Address configuration.
     * @dev Mapping from address to AddressConfiguration.
     */
    mapping(address => AddressConfiguration) internal addressConfiguration;

    /**
     * @notice Max amount of fees.
     */
    uint256 public constant MAX_FEES = 10_000;

    /**
     * @notice Fee rate denominator.
     * @dev Denominator for computing basis point fees.
     */
    uint256 public constant FEE_RATE_DENOMINATOR = 10_000;

    /**
     * @notice Constructor.
     * @dev Reverts with OverMaxBasisPoints when fees are greater than MAX_FEES.
     */
    constructor(address _treasury, uint16 _transferFee, uint16 _buyFee, uint16 _sellFee) {
        if (_transferFee > MAX_FEES || _buyFee > MAX_FEES || _sellFee > MAX_FEES) {
            revert OverMaxBasisPoints();
        }

        tokenConfiguration = TokenConfiguration({
            treasury: _treasury,
            transferFeesBPs: _transferFee,
            buyFeesBPs: _buyFee,
            sellFeesBPs: _sellFee
        });

        addressConfiguration[msg.sender] = AddressConfiguration({whitelisted: true, liquidityPair: false});
    }

    /**
     * @notice Sets the treasury address.
     * @param _treasury The new treasury address.
     */
    function setTreasury(address _treasury) external onlyOwner {
        tokenConfiguration.treasury = _treasury;
    }

    /**
     * @notice Sets the transfer fee rate.
     * @dev Reverts with OverMaxBasisPoints when fees are greater than MAX_FEES.
     * @param fees The new basis point value for the fee type.
     */
    function setTransferFeesBPs(uint16 fees) external onlyOwner {
        if (fees > MAX_FEES) {
            revert OverMaxBasisPoints();
        }
        tokenConfiguration.transferFeesBPs = fees;
    }

    /**
     * @notice Sets the buy fee rate.
     * @dev Reverts with OverMaxBasisPoints when fees are greater than MAX_FEES.
     * @param fees The new basis point value for the fee type.
     */
    function setBuyFeesBPs(uint16 fees) external onlyOwner {
        if (fees > MAX_FEES) {
            revert OverMaxBasisPoints();
        }
        tokenConfiguration.buyFeesBPs = fees;
    }

    /**
     * @notice Sets the sell fee rate.
     * @dev Reverts with OverMaxBasisPoints when fees are greater than MAX_FEES.
     * @param fees The new basis point value for the fee type.
     */
    function setSellFeesBPs(uint16 fees) external onlyOwner {
        if (fees > MAX_FEES) {
            revert OverMaxBasisPoints();
        }
        tokenConfiguration.sellFeesBPs = fees;
    }

    /**
     * @notice Adds or removes an address from the fee whitelist.
     * @param _address The address to update the whitelist status.
     * @param _status The new whitelist status (true: whitelisted, false: not whitelisted).
     */
    function feeWL(address _address, bool _status) external onlyOwner {
        addressConfiguration[_address].whitelisted = _status;
    }

    /**
     * @notice Adds or removes an address from the liquidity pair list.
     * @param _address The address to update the liquidity pair status.
     * @param _status The new liquidity pair status (true: liquidity pair, false: not liquidity pair).
     */
    function liquidityPairList(address _address, bool _status) external onlyOwner {
        addressConfiguration[_address].liquidityPair = _status;
    }

    /**
     * @notice Returns treasury address.
     * @return Treasury address.
     */
    function treasury() public view returns (address) {
        return tokenConfiguration.treasury;
    }

    /**
     * @notice Returns transfer fees basis points.
     * @return Transfer fees.
     */
    function transferFeesBPs() public view returns (uint256) {
        return tokenConfiguration.transferFeesBPs;
    }

    /**
     * @notice Returns buy fees basis points.
     * @return Buy fees.
     */
    function buyFeesBPs() public view returns (uint256) {
        return tokenConfiguration.buyFeesBPs;
    }

    /**
     * @notice Returns sell fees basis points.
     * @return Sell fees.
     */
    function sellFeesBPs() public view returns (uint256) {
        return tokenConfiguration.sellFeesBPs;
    }

    /**
     * @notice Returns the fee rate for a specific transaction.
     * @param from The sender address.
     * @param to The recipient address.
     * @return The fee rate for the transaction.
     */
    function getFeeRate(address from, address to) public view returns (uint256) {
        AddressConfiguration memory fromConfiguration = addressConfiguration[from];

        // If 'from' is whitelisted, no tax is applied
        if (fromConfiguration.whitelisted) {
            return 0;
        }

        AddressConfiguration memory toConfiguration = addressConfiguration[to];

        // If 'to' is whitelisted, no tax is applied
        if (toConfiguration.whitelisted) {
            return 0;
        }

        TokenConfiguration memory configuration = tokenConfiguration;

        // If 'from' is a liquidity pair, apply buy tax
        if (fromConfiguration.liquidityPair) {
            return configuration.buyFeesBPs;
        }

        // If 'to' is a liquidity pair, apply sell tax
        if (toConfiguration.liquidityPair) {
            return configuration.sellFeesBPs;
        }

        // Neither 'from' nor 'to' is a liquidity pair, apply transfer tax
        return configuration.transferFeesBPs;
    }

    /**
     * @notice Return whether account is whitelited.
     * @param account Account address.
     * @return Account whitelited.
     */
    function isFeeWhitelisted(address account) public view returns (bool) {
        return addressConfiguration[account].whitelisted;
    }

    /**
     * @notice Return whether account is liquidity pair.
     * @param account Account address.
     * @return Liquidity pair.
     */
    function isLiquidityPair(address account) public view returns (bool) {
        return addressConfiguration[account].liquidityPair;
    }

    /**
     * @notice Overrides the _transfer function of the ERC20 contract to apply taxes.
     * @param from The sender address.
     * @param to The recipient address.
     * @param amount The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        AddressConfiguration memory fromConfiguration = addressConfiguration[from];

        // If 'from' is whitelisted, no tax is applied
        if (fromConfiguration.whitelisted) {
            super._transfer(from, to, amount);
            return;
        }

        AddressConfiguration memory toConfiguration = addressConfiguration[to];

        // If 'to' is whitelisted, no tax is applied
        if (toConfiguration.whitelisted) {
            super._transfer(from, to, amount);
            return;
        }

        uint256 fee;
        TokenConfiguration memory configuration = tokenConfiguration;

        // If 'from' is a liquidity pair, apply buy tax
        if (fromConfiguration.liquidityPair) {
            unchecked {
                fee = amount * configuration.buyFeesBPs / FEE_RATE_DENOMINATOR;
            }
        }
        // If 'to' is a liquidity pair, apply sell tax
        else if (toConfiguration.liquidityPair) {
            unchecked {
                fee = amount * configuration.sellFeesBPs / FEE_RATE_DENOMINATOR;
            }
        }
        // Neither 'from' nor 'to' is a liquidity pair, apply transfer tax
        else {
            unchecked {
                fee = amount * configuration.transferFeesBPs / FEE_RATE_DENOMINATOR;
            }
        }

        // Cannot underflow since feeRate is max 100% of amount
        uint256 amountAfterFee;
        unchecked {
            amountAfterFee = amount - fee;
        }

        super._transfer(from, to, amountAfterFee);
        super._transfer(from, configuration.treasury, fee);
    }
}
