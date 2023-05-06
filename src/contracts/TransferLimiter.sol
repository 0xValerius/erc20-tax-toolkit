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
 * @title TransferLimiter
 * @author 0xValerius
 * @notice The TransferLimiter contract is an abstract contract that extends ERC20 and Ownable.
 * It provides functionality to limit the maximum transfer amount of tokens for non-whitelisted
 * addresses. Addresses can be whitelisted to bypass the transfer limit.
 *
 * Note: Contract should be used as a parent contract for custom ERC20 tokens that require
 * transfer limiting functionality.
 */
abstract contract TransferLimiter is ERC20, Ownable {
    uint256 public constant TRANSFER_LIMIT_DENOMINATOR = 10000;
    uint256 public basePointsTransferLimit;
    mapping(address => bool) public isTransferLimitWhitelisted;

    constructor(uint256 _basePointsTranferLimit) {
        basePointsTransferLimit = _basePointsTranferLimit;
        isTransferLimitWhitelisted[msg.sender] = true;
    }

    /**
     * @notice Adds or removes an address from the transfer limit whitelist.
     * @param _address The address to update the whitelist status.
     * @param _status The new whitelist status (true: whitelisted, false: not whitelisted).
     */
    function transferLimitWL(address _address, bool _status) external onlyOwner {
        isTransferLimitWhitelisted[_address] = _status;
    }

    /**
     * @notice Returns the maximum allowed transfer amount.
     * @return The allowed transfer amount.
     */
    function allowedAmount() public view returns (uint256) {
        return (totalSupply() * basePointsTransferLimit) / TRANSFER_LIMIT_DENOMINATOR;
    }

    /**
     * @notice Overrides the _beforeTokenTransfer function to enforce transfer limits.
     * @param from The sender address.
     * @param to The recipient address.
     * @param amount The amount of tokens to transfer.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        if (!isTransferLimitWhitelisted[from] && !isTransferLimitWhitelisted[to]) {
            require(amount <= allowedAmount(), "TransferLimiter: transfer amount exceeds limit");
        }
    }
}
