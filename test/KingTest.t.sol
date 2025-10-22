// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import {Attack, King} from "../src/King.sol";

contract KingTest is Test {
    King kg;
    Attack atck;
    address user;
    uint256 userPrivKey;

    function setUp() public {
        (user, userPrivKey) = makeAddrAndKey("user");
        vm.deal(user, 1 ether);
        vm.startBroadcast(userPrivKey);
        kg = new King{value: 1 ether}();
        atck = new Attack(address(kg));
        vm.stopBroadcast();
        vm.deal(address(atck), 2 ether);
        console.log("Tatck address is  ", address(atck));
        console.log("user address is ", user);
    }

    function testDoSOnKingContract() public {
        console.log("The king of contract is ", kg._king());
        vm.prank(user);
        atck.attack();
        console.log("The king of contract is ", kg._king());
        vm.expectRevert();
        hoax(user, 3 ether);
        //Va poser un problème parce que le smart contract Attack n'a pas de fallback
        //ou de receive pour receivoir les fonds
        address(kg).call{value: user.balance}("");
    }
}
