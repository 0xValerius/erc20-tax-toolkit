// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/StdUtils.sol";
import {TransferLimitedToken} from "../src/TransferLimitedToken.sol";

contract TransferLimitedTokenTest is Test {
    // state variable for the contract we want to test
    TransferLimitedToken token;

    // state variables for the actors in the test
    address owner = makeAddr("owner");
    address actor1 = makeAddr("actor1");
    address actor2 = makeAddr("actor2");

    uint256 initialTokenActorBalance = 1 * 10 ** 18;
    uint256 baiscPointsTransferLimit = 1000;

    // setUp() runs before every single test-case.
    // Each test case uses a new/initial state each time based on actions here.
    function setUp() public {
        vm.prank(owner);
        token = new TransferLimitedToken("MockToken", "MTK", baiscPointsTransferLimit);

        deal(address(token), owner, initialTokenActorBalance, true);
        deal(address(token), actor1, initialTokenActorBalance, true);
        deal(address(token), actor2, initialTokenActorBalance, true);
    }

    function test_MockTokenDeploy() public {
        assertEq(token.name(), "MockToken");
        assertEq(token.symbol(), "MTK");
        assertEq(token.totalSupply(), 3 * initialTokenActorBalance);
        assertEq(token.owner(), owner);
        assertEq(token.basePointsTransferLimit(), 1000);
    }

    function test_AllowedAmount() public {
        assertEq(token.allowedAmount(), (3 * initialTokenActorBalance * baiscPointsTransferLimit) / 10000);

        deal(address(token), actor1, 2 * initialTokenActorBalance, true);
        assertEq(token.allowedAmount(), (4 * initialTokenActorBalance * baiscPointsTransferLimit) / 10000);
    }

    function test_AddRemoveToWhitelist() public {
        assertEq(token.isTransferLimitWhitelisted(owner), true);
        assertEq(token.isTransferLimitWhitelisted(actor1), false);
        assertEq(token.isTransferLimitWhitelisted(actor2), false);

        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.addTransferLimit(actor2);

        vm.prank(owner);
        token.addTransferLimit(actor1);
        assertEq(token.isTransferLimitWhitelisted(actor1), true);

        vm.prank(owner);
        token.removeTransferLimit(actor1);
        assertEq(token.isTransferLimitWhitelisted(actor1), false);
    }

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
        token.addTransferLimit(actor2);

        vm.prank(actor2);
        token.transfer(actor1, initialTokenActorBalance);
        assertEq(token.balanceOf(actor1), 2 * initialTokenActorBalance);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance);
    }
}
