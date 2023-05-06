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
import {TaxHandledToken} from "../src/tokens/TaxHandledToken.sol";

/// @title TaxHandledToken
/// @notice A test suite for the TaxHandledToken smart contract
contract TaxHandledTokenTest is Test {
    // state variable for the contract we want to test
    TaxHandledToken token;

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

    /// @notice Sets up the initial state for each test case
    function setUp() public {
        vm.startPrank(owner);
        token = new TaxHandledToken('MockToken', 'MTK', treasury, transferFee, buyFee,
        sellFee);
        token.feeWL(treasury, true);

        // set liqiduity pair for buy / sell fees
        token.liquidityPairList(liquidityPair, true);
        vm.stopPrank();

        deal(address(token), owner, initialTokenActorBalance, true);
        deal(address(token), actor1, initialTokenActorBalance, true);
        deal(address(token), actor2, initialTokenActorBalance, true);
        deal(address(token), liquidityPair, initialTokenActorBalance, true);
    }

    /// @notice Tests the constructor and initialization of the token contract
    function test_MockTokenDeploy() public {
        assertEq(token.name(), "MockToken");
        assertEq(token.symbol(), "MTK");
        assertEq(token.treasury(), treasury);
        assertEq(token.basisPointsFee(0), transferFee);
        assertEq(token.basisPointsFee(1), buyFee);
        assertEq(token.basisPointsFee(2), sellFee);
        assertEq(token.totalSupply(), 4 * initialTokenActorBalance);
        assertEq(token.isFeeWhitelisted(owner), true);
        assertEq(token.isFeeWhitelisted(treasury), true);
        assertEq(token.isLiquidityPair(liquidityPair), true);
    }

    /// @notice Tests setting the treasury address
    function test_setTreasury() public {
        // verify onlyOwner
        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTreasury(address(0x1234));

        vm.prank(owner);
        token.setTreasury(address(0x1234));
        assertEq(token.treasury(), address(0x1234));
    }

    /// @notice Tests setting the fee rates
    function test_setFeeRate() public {
        // verify onlyOwner
        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setFees(0, 200);

        vm.prank(owner);
        token.setFees(0, 200);
        assertEq(token.basisPointsFee(0), 200);
    }

    /// @notice Tests adding and removing a liquidity pair
    function test_addRemoveLiquidityPair() public {
        // verify onlyOwner
        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.liquidityPairList(address(0x1234), true);

        vm.startPrank(owner);
        token.liquidityPairList(address(0x1234), true);
        assertEq(token.isLiquidityPair(address(0x1234)), true);
        token.liquidityPairList(address(0x1234), false);
        vm.stopPrank();
        assertEq(token.isLiquidityPair(address(0x1234)), false);
    }

    /// @notice Tests adding and removing a fee whitelist
    function test_AddRemoveWhitelist() public {
        // verify onlyOwner
        vm.prank(actor1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.feeWL(address(0x1234), true);

        vm.startPrank(owner);
        token.feeWL(address(0x1234), true);
        assertEq(token.isFeeWhitelisted(address(0x1234)), true);
        token.feeWL(address(0x1234), false);
        vm.stopPrank();
        assertEq(token.isFeeWhitelisted(address(0x1234)), false);
    }

    /// @notice Tests getting the fee rate for a given pair of addresses
    function test_getFeeRate() public {
        assertEq(token.getFeeRate(owner, actor1), 0);
        assertEq(token.getFeeRate(actor1, owner), 0);
        assertEq(token.getFeeRate(actor1, actor2), transferFee);
        assertEq(token.getFeeRate(liquidityPair, actor1), buyFee);
        assertEq(token.getFeeRate(actor1, liquidityPair), sellFee);
    }

    /// @notice Tests the transfer function between whitelisted addresses
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

    /// @notice Tests the transfer tax between non-whitelisted addresses
    function test_UserToUserTransfer() public {
        // transfer from actor1 to actor2
        vm.prank(actor1);
        token.transfer(actor2, 1000);
        assertEq(token.balanceOf(actor1), initialTokenActorBalance - 1000);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance + 990);
        assertEq(token.balanceOf(treasury), 10);
    }

    /// @notice Tests the buy tax
    function test_BuyTransfer() public {
        // actor1 buys
        vm.prank(liquidityPair);
        token.transfer(actor1, 1000);
        assertEq(token.balanceOf(liquidityPair), initialTokenActorBalance - 1000);
        assertEq(token.balanceOf(actor1), initialTokenActorBalance + 980);
        assertEq(token.balanceOf(treasury), 20);

        // whitelisted address buys
        vm.prank(liquidityPair);
        token.transfer(owner, 1000);
        assertEq(token.balanceOf(liquidityPair), initialTokenActorBalance - 2000);
        assertEq(token.balanceOf(owner), initialTokenActorBalance + 1000);
        assertEq(token.balanceOf(treasury), 20);
    }

    /// @notice Tests the sell tax
    function test_SellTransfer() public {
        // actor2 sells
        vm.prank(actor2);
        token.transfer(liquidityPair, 1000);
        assertEq(token.balanceOf(liquidityPair), initialTokenActorBalance + 970);
        assertEq(token.balanceOf(actor2), initialTokenActorBalance - 1000);
        assertEq(token.balanceOf(treasury), 30);

        // whitelisted address sells
        vm.prank(owner);
        token.transfer(liquidityPair, 1000);
        assertEq(token.balanceOf(liquidityPair), initialTokenActorBalance + 1970);
        assertEq(token.balanceOf(owner), initialTokenActorBalance - 1000);
        assertEq(token.balanceOf(treasury), 30);
    }
}
