// The goal of this level is for you to claim ownership of the instance you are given.

//   Things that might help

// Look into Solidity's documentation on the delegatecall low level function, how it works, how it can be used to delegate operations to on-chain libraries, and what implications it has on execution scope.
// Fallback methods
// Method ids
//Result
//To claim ownership of Delegate instance given to you in Delegation contract you must
//use address(the_Delegation_contract_deployed).call(abi.encodeWithSignature("pwn()"))
//Delegation instance will execute automatically the fallback function and
//modify the owner address at slot 0 in his storage and you'll be the ownership of the contract

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {console} from "forge-std/Test.sol";

contract Delegate {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function pwn() public {
        console.log("msg.sender is in pwn ", msg.sender);
        owner = msg.sender;
    }
}

contract Delegation {
    address public owner;
    Delegate delegate;

    constructor(address _delegateAddress) {
        delegate = Delegate(_delegateAddress);
        owner = msg.sender;
    }

    //Pour que le fallback soir appelé je dois essayer de transferer un montant d'ethers
    //au contract Delegation
    // fallback() external {
    //     console.log("msg.sender is ", msg.sender);
    //     console.log("fallback called and msg.data is ");
    //     console.logBytes(msg.data);
    //     //qaund c'est call le msg.sender devient alors le contract qui fait appel a pwn
    //     //ici Delegation
    //     //mais si c'est delegatecall le msg.sender meme dans la fonction pwn du contract Delegate
    //     //reste le EOA qui a inité la tx
    //     //C'est comme ci Delegation execute la fonction pwn a l'interieur de lui
    //     //meme et donc modifie son slot 0 qui correspond a owner
    //     (bool result, ) = address(delegate).delegatecall(msg.data);
    //     console.log("delegatecall result is ", result);
    //     if (result) {
    //         this;
    //     }
    // }
}

contract DoS {
    uint256 gas = gasleft();

    function test() public pure {
        console.log("test");
    }

    // uint256 gasBefore = gasleft();

    fallback() external {
        //console.log("gas before is  ", gasBefore);
        //console.log("gas after is  ", gasleft());
        console.log("");
    }
}
