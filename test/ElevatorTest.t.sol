// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import "../src/Elevator.sol";

contract ElevatorTest is Test {
    Elevator elv;
    Attack atck;

    function setUp() public {
        vm.broadcast();
        elv = new Elevator();
        atck = new Attack();
    }

    function testGoToFloor() public {
        assertEq(elv.floor(), 0);
        assert(!elv.top());
        vm.prank(address(atck));
        elv.goTo(2);
        assertEq(elv.floor(), 0);
        assert(!elv.top());
    }
}
