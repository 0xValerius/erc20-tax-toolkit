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
 * @title BlackLister
 * @author 0xValerius
 * @notice The BlackLister contract is an abstract contract that extends ERC20 and Ownable.
 * It provides functionality to blacklist addresses, preventing them from sending or receiving
 * tokens. The contract owner can add or remove addresses from the blacklist.
 *
 * Note: Contract should be used as a parent contract for custom ERC20 tokens that require
 * blacklisting functionality.
 */
abstract contract BlackLister is ERC20, Ownable {
    mapping(address => bool) public isBlacklisted;

    /**
     * @notice Updates the blacklist status of the specified address.
     * Can only be called by the contract owner.
     * @param _address The address to be updated.
     * @param _status The new blacklist status for the address.
     */
    function blacklist(address _address, bool _status) external onlyOwner {
        isBlacklisted[_address] = _status;
    }

    /**
     * @notice Hook that is called before any token transfer. Prevents transfers involving
     * blacklisted addresses.
     * @param from The address tokens are transferred from.
     * @param to The address tokens are transferred to.
     * @param amount The amount of tokens being transferred.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!isBlacklisted[from] && !isBlacklisted[to], "Blacklister: blacklisted address.");
    }
}
