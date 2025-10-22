// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Script, console} from "forge-std/Script.sol";
import "../src/Recovery.sol";

contract Deposit is Script {
    function depositToAccount(address account, uint256 _value) external {
        account.call{value: _value}("");
    }
}

// contract RecoverEther is Script {
//     Recovery rec;
//     function getCreateRecoveryAddress(uint8 nonce) public{

//     }
// }
