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

import "forge-std/Test.sol";
import "forge-std/StdUtils.sol";
import {BlackListerToken} from "../src/tokens/BlackListerToken.sol";

/// @title BlackListerToken
/// @notice A test suite for the BlackListerToken smart contract
contract BlackListerTokenTest is Test {
    // state variable for the contract we want to test
    BlackListerToken token;

    // state variables for the actors in the test
    address owner = makeAddr("ownenr");
    address actor1 = makeAddr("actor1");
    address actor2 = makeAddr("actor2");

    uint256 initialTokenActorBalance = 1 * 10 ** 18;

    /// @notice Sets up the initial state for each test case
    function setUp() public {
        vm.prank(owner);
        token = new BlackListerToken("MockToken", "MTK");

        deal(address(token), owner, initialTokenActorBalance, true);
        deal(address(token), actor1, initialTokenActorBalance, true);
        deal(address(token), actor2, initialTokenActorBalance, true);
    }

    /// @notice Tests the constructor and initialization of the token contract
    function test_MockTokenDeploy() public {
        assertEq(token.name(), "MockToken");
        assertEq(token.symbol(), "MTK");
        assertEq(token.totalSupply(), 3 * initialTokenActorBalance);
        assertEq(token.owner(), owner);
        assertEq(token.isBlacklisted(owner), false);
        assertEq(token.isBlacklisted(actor1), false);
        assertEq(token.isBlacklisted(actor2), false);
    }

    /// @notice Tests adding and removing an address to/from the blacklist
    function test_AddRemoveToBlacklist() public {
        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.blacklist(actor2, true);

        vm.prank(owner);
        token.blacklist(actor2, true);
        assertEq(token.isBlacklisted(actor2), true);

        vm.prank(owner);
        token.blacklist(actor2, false);
        assertEq(token.isBlacklisted(actor2), false);
    }

    /// @notice Tests transfers to and from a blacklisted address
    function test_BlackListedTransfer() public {
        // actor1 not blacklisted
        vm.prank(actor1);
        token.transfer(actor2, 100);
        assertEq(token.balanceOf(actor1), initialTokenActorBalance - 100);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance + 100);

        // actor1 blacklisted outbound
        vm.prank(owner);
        token.blacklist(actor1, true);
        vm.prank(actor1);
        vm.expectRevert("Blacklister: blacklisted address.");
        token.transfer(actor2, 100);
        assertEq(token.balanceOf(actor1), initialTokenActorBalance - 100);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance + 100);

        // actor1 blacklisted inbound
        vm.prank(actor2);
        vm.expectRevert("Blacklister: blacklisted address.");
        token.transfer(actor1, 100);
        assertEq(token.balanceOf(actor1), initialTokenActorBalance - 100);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance + 100);
    }
}
