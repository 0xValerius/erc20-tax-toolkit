// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/StdUtils.sol";
import {BalanceTransferLimitedToken} from "../src/BalanceTransferLimitedToken.sol";

contract BalanceTransferLimitedTokenTest is Test {
    // state variable for the contract we want to test
    BalanceTransferLimitedToken token;

    // state variables for the actors in the test
    address owner = makeAddr("owner");
    address actor1 = makeAddr("actor1");
    address actor2 = makeAddr("actor2");
    address actor3 = makeAddr("actor3");

    uint256 initialTokenActorBalance = 1 * 10 ** 18;
    uint256 basePointsBalanceLimit = 1000;
    uint256 basePointsTransferLimit = 500;

    // setUp() runs before every single test-case.
    // Each test case uses a new/initial state each time based on actions here.
    function setUp() public {
        vm.prank(owner);
        token = new BalanceTransferLimitedToken(
            "MockToken",
            "MTK",
            basePointsBalanceLimit,
            basePointsTransferLimit
            );

        deal(address(token), owner, initialTokenActorBalance, true);
        deal(address(token), actor1, initialTokenActorBalance, true);
        deal(address(token), actor2, initialTokenActorBalance, true);
        deal(address(token), actor3, initialTokenActorBalance, true);
    }

    function test_MockTokenDeploy() public {
        assertEq(token.name(), "MockToken");
        assertEq(token.symbol(), "MTK");
        assertEq(token.totalSupply(), 4 * initialTokenActorBalance);
        assertEq(token.owner(), owner);
        assertEq(token.basePointsBalanceLimit(), 1000);
        assertEq(token.basePointsTransferLimit(), 500);
    }

    function test_AllowedTransferBalanceAmount() public {
        assertEq(token.allowedMaxBalance(), (4 * initialTokenActorBalance * basePointsBalanceLimit) / 10000);
        assertEq(token.allowedAmount(), (4 * initialTokenActorBalance * basePointsTransferLimit) / 10000);

        deal(address(token), actor1, 2 * initialTokenActorBalance, true);
        assertEq(token.allowedMaxBalance(), (5 * initialTokenActorBalance * basePointsBalanceLimit) / 10000);
        assertEq(token.allowedAmount(), (5 * initialTokenActorBalance * basePointsTransferLimit) / 10000);
    }

    function test_AddRemoveToWhitelist() public {
        assertEq(token.isBalanceLimitWhitelisted(owner), true);
        assertEq(token.isBalanceLimitWhitelisted(actor1), false);
        assertEq(token.isBalanceLimitWhitelisted(actor2), false);

        assertEq(token.isTransferLimitWhitelisted(owner), true);
        assertEq(token.isTransferLimitWhitelisted(actor1), false);
        assertEq(token.isTransferLimitWhitelisted(actor2), false);

        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.balanceLimitWL(actor2, true);

        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.removeTransferLimit(actor2);

        vm.prank(owner);
        token.balanceLimitWL(actor1, true);
        assertEq(token.isBalanceLimitWhitelisted(actor1), true);

        vm.prank(owner);
        token.removeTransferLimit(actor1);
        assertEq(token.isTransferLimitWhitelisted(actor1), true);
    }

    function test_TransferLimit() public {
        vm.prank(actor1);
        vm.expectRevert("TransferLimiter: transfer amount exceeds limit");
        token.transfer(actor2, initialTokenActorBalance / 3);
        assertEq(token.balanceOf(actor1), initialTokenActorBalance);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance);

        vm.prank(owner);
        token.transfer(actor2, initialTokenActorBalance);
        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(actor2), 2 * initialTokenActorBalance);
    }

    function test_BalanceLimit() public {
        // remove transfer limit
        vm.startPrank(owner);
        token.removeTransferLimit(actor1);
        token.removeTransferLimit(actor2);
        vm.stopPrank();

        vm.prank(actor1);
        vm.expectRevert("BalanceLimiter: balance amount exceeds limit");
        token.transfer(actor2, initialTokenActorBalance);
        assertEq(token.balanceOf(actor1), initialTokenActorBalance);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance);

        vm.prank(owner);
        token.transfer(actor2, initialTokenActorBalance);
        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(actor2), 2 * initialTokenActorBalance);

        vm.prank(owner);
        token.balanceLimitWL(actor2, true);

        vm.prank(actor2);
        token.transfer(actor1, initialTokenActorBalance);
        assertEq(token.balanceOf(actor1), 2 * initialTokenActorBalance);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance);
    }
}
