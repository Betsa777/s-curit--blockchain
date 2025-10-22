// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Denial, Attack} from "../src/Denial.sol";

contract DenialTest is Test {
    Denial denial;
    Attack atck;

    function setUp() public {
        denial = new Denial();
        atck = new Attack();
    }

    function test_Partner_attack_consume_all_the_available_gas() public {
        denial.setWithdrawPartner(address(atck));
        denial.withdraw();
    }
}
