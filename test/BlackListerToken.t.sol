// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/StdUtils.sol";
import {BlackListerToken} from "../src/BlackListerToken.sol";

contract BlackListerTokenTest is Test {
    // state variable for the contract we want to test
    BlackListerToken token;

    // state variables for the actors in the test
    address owner = makeAddr("ownenr");
    address actor1 = makeAddr("actor1");
    address actor2 = makeAddr("actor2");

    uint256 initialTokenActorBalance = 1 * 10 ** 18;

    // setUp() runs before every single test-case.
    // Each test case uses a new/initial state each time based on actions here.
    function setUp() public {
        vm.prank(owner);
        token = new BlackListerToken("MockToken", "MTK");

        deal(address(token), owner, initialTokenActorBalance, true);
        deal(address(token), actor1, initialTokenActorBalance, true);
        deal(address(token), actor2, initialTokenActorBalance, true);
    }

    function test_MockTokenDeploy() public {
        assertEq(token.name(), "MockToken");
        assertEq(token.symbol(), "MTK");
        assertEq(token.totalSupply(), 3 * initialTokenActorBalance);
        assertEq(token.owner(), owner);
        assertEq(token.isBlacklisted(owner), false);
        assertEq(token.isBlacklisted(actor1), false);
        assertEq(token.isBlacklisted(actor2), false);
    }

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
