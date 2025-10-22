// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/Shop.sol";

contract ShopTest is Test {
    Shop shop;
    Attack atck;

    function setUp() public {
        shop = new Shop();
        atck = new Attack(address(shop));
    }

    function testAttack() public {
        atck.attack();
        assertEq(atck.price() - 1, shop.price());
    }
}
