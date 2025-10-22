// Unlock the vault to pass the level!

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vault {
    bool public locked;
    //data on blockchain are not private
    bytes32 private password;

    constructor(bytes32 _password) {
        locked = true;
        password = _password;
    }

    //considere doing
    /* function unlock(string calldata _password){
    if (password == keccak256(_password)) {
            locked = false;
        }
          }
        But if someone get this transaction data and see that is called unlock function
        with this _password and after this locked became false it can know the _password.
        So don't put any sensitive data onchain
          */
    function unlock(bytes32 _password) public {
        if (password == _password) {
            locked = false;
        }
    }
}
//I will do it be using cast an chisel
/* 
➜ bytes32 result = keccak256("mypassword")
➜ result
Type: bytes32
└ Data: 0x5064b09d713b0348f248cf83fedef649ecdc1121d0913a67adb84438d1cb8422

-> Deploy the contract
forge create src/Vault.sol:Vault --constructor-args 0x5064b09d713b0348f248cf83fedef649ecdc1121d0913a67adb84438d1cb8422 
--rpc-url 127.0.0.1:8545 --account anvil

-> Get the password by using cast because any data on blockchain is private even if
it is declared with private visibility

V=0x5FbDB2315678afecb367f032d93F642f64180aa3 which is the contract address
cast storage $V 1  --rpc-url 127.0.0.1:8545
output: 0x5064b09d713b0348f248cf83fedef649ecdc1121d0913a67adb84438d1cb8422

cast send $V "unlock(bytes32)" 0x5064b09d713b0348f248cf83fedef649ecdc1121d0913a67adb84438d1cb8422
--rpc-url 127.0.0.1:8545 --account anvil
cast storage $V 0  --rpc-url 127.0.0.1:8545
0x0000000000000000000000000000000000000000000000000000000000000000
*/
