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
import {TransferLimitedToken} from "../src/tokens/TransferLimitedToken.sol";

/// @title TransferLimitedToken
/// @notice A test suite for the TransferLimitedToken smart contract
contract TransferLimitedTokenTest is Test {
    // state variable for the contract we want to test
    TransferLimitedToken token;

    // state variables for the actors in the test
    address owner = makeAddr("owner");
    address actor1 = makeAddr("actor1");
    address actor2 = makeAddr("actor2");

    uint256 initialTokenActorBalance = 1 * 10 ** 18;
    uint256 baiscPointsTransferLimit = 1000;

    /// @notice Sets up the initial state for each test case
    function setUp() public {
        vm.prank(owner);
        token = new TransferLimitedToken("MockToken", "MTK", baiscPointsTransferLimit);

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
        assertEq(token.basePointsTransferLimit(), 1000);
    }

    /// @notice Tests the allowed amount of tokens that can be transferred
    function test_AllowedAmount() public {
        assertEq(token.allowedAmount(), (3 * initialTokenActorBalance * baiscPointsTransferLimit) / 10000);

        deal(address(token), actor1, 2 * initialTokenActorBalance, true);
        assertEq(token.allowedAmount(), (4 * initialTokenActorBalance * baiscPointsTransferLimit) / 10000);
    }

    /// @notice Tests adding and removing addresses whitelist
    function test_AddRemoveToWhitelist() public {
        assertEq(token.isTransferLimitWhitelisted(owner), true);
        assertEq(token.isTransferLimitWhitelisted(actor1), false);
        assertEq(token.isTransferLimitWhitelisted(actor2), false);

        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.transferLimitWL(actor2, true);

        vm.prank(owner);
        token.transferLimitWL(actor1, true);
        assertEq(token.isTransferLimitWhitelisted(actor1), true);
    }

    /// @notice Tests the transfer limit
    function test_TransferLimit() public {
        vm.prank(actor1);
        vm.expectRevert("TransferLimiter: transfer amount exceeds limit");
        token.transfer(actor2, initialTokenActorBalance);
        assertEq(token.balanceOf(actor1), initialTokenActorBalance);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance);

        vm.prank(owner);
        token.transfer(actor2, initialTokenActorBalance);
        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(actor2), 2 * initialTokenActorBalance);

        vm.prank(owner);
        token.transferLimitWL(actor2, true);

        vm.prank(actor2);
        token.transfer(actor1, initialTokenActorBalance);
        assertEq(token.balanceOf(actor1), 2 * initialTokenActorBalance);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance);
    }
}
