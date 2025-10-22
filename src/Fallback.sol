// Il s'agit d'un jeu de lancer de pièce dans lequel vous devez accumuler
// vos victoires en devinant le résultat d'un tirage au sort. Pour terminer
// ce niveau, vous devrez utiliser vos capacités psychiques pour deviner le
// résultat correct 10 fois de suite.

//   Des choses qui pourraient aider

// vous revendiquez la propriété du contrat
// vous réduisez son solde à 0

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Fallback {
    mapping(address => uint256) public contributions;
    address public owner;

    constructor() {
        owner = msg.sender;
        contributions[msg.sender] = 1000 * (1 ether);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function contribute() public payable {
        require(msg.value < 0.001 ether);
        contributions[msg.sender] += msg.value;
        if (contributions[msg.sender] > contributions[owner]) {
            owner = msg.sender;
        }
    }

    function getContribution() public view returns (uint256) {
        return contributions[msg.sender];
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    //La faille se trouve ici. Il me suffit d'appeler seulement
    //une instance de fallback avec un msg.value superieur a 0
    //et des données au niveau du call vide et je deviens le propriétaire du contract
    receive() external payable {
        require(msg.value > 0 && contributions[msg.sender] > 0);
        owner = msg.sender;
    }
}
