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
 * @title BalanceLimiter
 * @author 0xValerius
 * @notice The BalanceLimiter contract is an abstract contract that extends ERC20 and Ownable.
 * It provides functionality to limit the maximum balance of each non-whitelisted address based
 * on a configurable percentage of the total token supply. Addresses can be added to or removed
 * from the balance limit whitelist by the contract owner.
 *
 * Note: Contract should be used as a parent contract for custom ERC20 tokens that require balance
 * limiting functionality.
 */
abstract contract BalanceLimiter is ERC20, Ownable {
    uint256 public constant BALANCE_LIMIT_DENOMINATOR = 10000;
    uint256 public basePointsBalanceLimit;
    mapping(address => bool) public isBalanceLimitWhitelisted;

    /**
     * @notice Sets the initial balance limit as a base points value (1 base point = 0.01%).
     * The contract creator is automatically whitelisted from balance limiting.
     * @param _basePointsBalanceLimit The balance limit value in base points.
     */
    constructor(uint256 _basePointsBalanceLimit) {
        basePointsBalanceLimit = _basePointsBalanceLimit;
        isBalanceLimitWhitelisted[msg.sender] = true;
    }

    /**
     * @notice Updates the balance limit whitelist status of the specified address.
     * Can only be called by the contract owner.
     * @param _address The address to be updated.
     * @param _status The new whitelist status for the address.
     */
    function balanceLimitWL(address _address, bool _status) external onlyOwner {
        isBalanceLimitWhitelisted[_address] = _status;
    }

    /**
     * @notice Calculates the allowed maximum balance based on the total token supply and
     * the configured balance limit.
     * @return The allowed maximum balance.
     */
    function allowedMaxBalance() public view returns (uint256) {
        return (totalSupply() * basePointsBalanceLimit) / BALANCE_LIMIT_DENOMINATOR;
    }

    /**
     * @notice Hook that is called before any token transfer. Checks if the transfer
     * would exceed the allowed maximum balance for non-whitelisted addresses.
     * @param from The address tokens are transferred from.
     * @param to The address tokens are transferred to.
     * @param amount The amount of tokens being transferred.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        if (!isBalanceLimitWhitelisted[from] && !isBalanceLimitWhitelisted[to]) {
            require(amount <= allowedMaxBalance(), "BalanceLimiter: balance amount exceeds limit");
        }
    }
}
