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
        vm.startPrank(owner);
        token = new BlackListerToken("MockToken", "MTK");
        vm.stopPrank();

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
}
