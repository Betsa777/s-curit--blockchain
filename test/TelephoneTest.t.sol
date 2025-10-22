// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import "../src/Telephone.sol";

contract TelephoneTest is Test {
    Telephone tel;
    Attack atck;
    address alice;
    uint256 alicePrivKey;

    function setUp() public {
        (alice, alicePrivKey) = makeAddrAndKey("alice");
        vm.startBroadcast(alicePrivKey);
        tel = new Telephone();
        atck = new Attack(address(tel));
        vm.stopBroadcast();
        console.log("Alice address is ", alice);
        console.log("telephone owner address is ", tel.owner());
    }

    function testClaimOwnerShip() public {
        address one = address(1);
        vm.prank(alice);
        assertTrue(alice == tel.owner());
        atck.attack(one);
        console.log("telephone owner address is now", tel.owner());
        assertTrue(one == tel.owner());
    }
}
