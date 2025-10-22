// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import "../src/GateKeeperOne.sol";

contract GateKeeperOneTest is Test {
    GatekeeperOne gate;
    Attack atck;

    function setUp() public {
        gate = new GatekeeperOne();
        atck = new Attack(address(gate));
    }

    function testGatePass() public {
        // for (uint256 i = 0; i < 8191 * 10; i++) {
        // Itère sur plusieurs tentatives
        try atck.attack() {
            // console.log("Condition satisfied with gas:", i * 8191);
            //break; // Arrête la boucle si la condition est remplie
        } catch {
            // Ignore l'erreur si la condition échoue
        }
        //}
    }

    function testGas() public {
        vm.expectRevert();
        uint256 gasStart = gasleft();
        require(gasleft() % 8191 == 0);
        console.log("le gaz utilise est ", gasStart - gasleft());
    }
}
