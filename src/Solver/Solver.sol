// Pour résoudre ce niveau, il vous suffit de fournir à l'Ethernaut un Solver, un contrat qui répond à whatIsTheMeaningOfLife()avec le bon numéro de 32 octets.

// Facile, non ? Bon... il y a un piège.

// Le code du solveur doit être vraiment minuscule. Vraiment trèèèèèèès petit. Comme tout petit : 10 octets au maximum.

// Astuce : il est peut-être temps de quitter momentanément le confort du compilateur Solidity et de construire celui-ci à la main O_o. C'est exact : du bytecode EVM brut.

//Le code pour donner la reponse 42 se trouver dans Solver.huff et fait 8 octets
//La logique est que dès que quelqu'un effectue un appel call via cast call par exemple que
//42 lui soit renvoyée automatiquement
//pas de verifiactions de fonctions ou quoi que ce soit juste renvoyé 42 pour tenir sur la limite des
//10 octets
//Je deplois le bytecode avec assembly(opcode create) dans le fichier
//HuffDeploy.s.sol et je calcule la taille du bytecode deployé ou le runtime bytecode(le code
//qui sera sur la blockchain) avec l'opcode extcodesize qui me renvoie 8 (8 octets)
//et je fais
//cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "whatIsTheMeaningOfLi()"  --rpc-url 127.0.0.1:8545
//output: 0x000000000000000000000000000000000000000000000000000000000000002a
//cast --to-dec 0x000000000000000000000000000000000000000000000000000000000000002a
//output: 42

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MagicNum {
    address public solver;

    constructor() {}

    function setSolver(address _solver) public {
        solver = _solver;
    }

    /*
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
    */
}
