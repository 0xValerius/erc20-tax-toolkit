// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/StdUtils.sol";
import {MockToken} from "../src/MockToken.sol";

contract MockTokenTest is Test {
    // state variable for the contract we want to test
    MockToken token;

    // state variables for the actors in the test
    address owner = makeAddr("ownenr");
    address actor1 = makeAddr("actor1");
    address actor2 = makeAddr("actor2");
    address treasury = makeAddr("treasury");
    address liquidityPair = makeAddr("uniswapV2Pair");

    uint256 transferFee = 100;
    uint256 buyFee = 200;
    uint256 sellFee = 300;

    uint256 initialTokenActorBalance = 1 * 10 ** 18;

    // setUp() runs before every single test-case.
    // Each test case uses a new/initial state each time based on actions here.
    function setUp() public {
        vm.startPrank(owner);
        token = new MockToken('MockToken', 'MTK', treasury, transferFee, buyFee,
        sellFee);
        token.addWhitelist(treasury);
        vm.stopPrank();
        deal(address(token), owner, initialTokenActorBalance, true);
        deal(address(token), actor1, initialTokenActorBalance, true);
        deal(address(token), actor2, initialTokenActorBalance, true);
        deal(address(token), liquidityPair, initialTokenActorBalance, true);
    }

    function test_MockTokenDeploy() public {
        assertEq(token.name(), "MockToken");
        assertEq(token.symbol(), "MTK");
        assertEq(token.treasury(), treasury);
        assertEq(token.basisPointsFee(0), transferFee);
        assertEq(token.basisPointsFee(1), buyFee);
        assertEq(token.basisPointsFee(2), sellFee);
        assertEq(token.totalSupply(), 4 * initialTokenActorBalance);
        assertEq(token.isTaxWhitelisted(owner), true);
        assertEq(token.isTaxWhitelisted(treasury), true);
    }

    function test_setTreasury() public {
        // verify onlyOwner
        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTreasury(address(0x1234));

        vm.prank(owner);
        token.setTreasury(address(0x1234));
        assertEq(token.treasury(), address(0x1234));
    }

    function test_setFeeRate() public {
        // verify onlyOwner
        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setFees(0, 200);

        vm.prank(owner);
        token.setFees(0, 200);
        assertEq(token.basisPointsFee(0), 200);
    }

    function test_addRemoveLiquidityPair() public {
        // verify onlyOwner
        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.addLiquidityPair(address(0x1234));

        vm.startPrank(owner);
        token.addLiquidityPair(address(0x1234));
        assertEq(token.isLiquidityPair(address(0x1234)), true);
        token.removeLiquidityPair(address(0x1234));
        vm.stopPrank();
    }

    function test_AddRemoveWhitelist() public {
        // verify onlyOwner
        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.addWhitelist(address(0x1234));

        vm.startPrank(owner);
        token.addWhitelist(address(0x1234));
        assertEq(token.isTaxWhitelisted(address(0x1234)), true);
        token.removeWhitelist(address(0x1234));
        vm.stopPrank();
        assertEq(token.isTaxWhitelisted(address(0x1234)), false);
    }

    function test_getFeeRate() public {}

    function test_WhiteListedTransfer() public {
        // transfer from owner to actor1
        vm.prank(owner);
        token.transfer(actor1, 1000);
        assertEq(token.balanceOf(owner), initialTokenActorBalance - 1000);
        assertEq(token.balanceOf(actor1), initialTokenActorBalance + 1000);
        assertEq(token.balanceOf(treasury), 0);

        // transfer from actor2 to owner
        vm.prank(actor2);
        token.transfer(owner, 1000);
        assertEq(token.balanceOf(owner), initialTokenActorBalance);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance - 1000);
        assertEq(token.balanceOf(treasury), 0);
    }

    function test_TaxOnTransfer() public {
        // transfer from actor1 to actor2
        vm.prank(actor1);
        token.transfer(actor2, 1000);
        assertEq(token.balanceOf(actor1), initialTokenActorBalance - 1000);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance + 990);
        assertEq(token.balanceOf(treasury), 10);
    }
}
