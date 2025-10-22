// SPDX-License-Identifier: MIT
// The creator of this contract was careful enough to protect the sensitive areas of its storage.

// Unlock this contract to beat the level.

// Things that might help:

// Understanding how storage works
// Understanding how parameter parsing works
// Understanding how casting works
pragma solidity ^0.8.0;

contract Privacy {
    bool public locked = true; //slot 0
    uint256 public ID = block.timestamp; // slot 1
    uint8 private flattening = 10; // slot 2
    uint8 private denomination = 255; // slot 2
    uint16 private awkwardness = uint16(block.timestamp); // slot 2
    bytes32[3] private data; //slot 3, slot 4, slot 5

    constructor(bytes32[3] memory _data) {
        data = _data;
    }

    //bytes16 _key represente ici les 16 bytes de poids forts de data[2]
    //ou les 128 bits en comptant de la gauche vers la droite de data[2]
    function unlock(bytes16 _key) public {
        require(_key == bytes16(data[2]), "not the key");
        locked = false;
    }

    /*
    A bunch of super advanced solidity algorithms...

      ,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`
      .,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,
      *.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^         ,---/V\
      `*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.    ~|__(o.o)
      ^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'  UU  UU
    */
}
/* 
La logique pour hacker ce contract:
-> Je localise le slot qui correspond a data[2] , ici le slot 5 
-> Je recupère la valeur au niveau de ce slot:
    cast storage $p 5 --rpc-url 127.0.0.1:8545
    output: 0x9e29ae33513b7fd1a85710d0c2f8bc0408eeffba89ca290e37c927a652bea8f4
-> J'ai besoin des 16 premiers bytes (128 premiers bits de poids forts ) de poids forts.
   Je lance chisel et je fais:
    bytes32 data = 0x9e29ae33513b7fd1a85710d0c2f8bc0408eeffba89ca290e37c927a652bea8f4;
➜ bytes32 move = data >> 128
move  donnera 0x000000000000000000000000000000009e29ae33513b7fd1a85710d0c2f8bc04
➜ bytes16 = bytes16(uint128(uint256(move)))
➜ bytes16 result= bytes16(uint128(uint256(move)))
➜ result
Type: bytes16
└ Data: 0x9e29ae33513b7fd1a85710d0c2f8bc0400000000000000000000000000000000

L'operateur >> me permet de decaler un nombre de bits de poids forts vers la droite(de la gauche vers
la droite) et je recupère ces valeurs avec bytes16(uint128(uint256(move))
Donc cette instruction me donnera les 16 bytes de poids faibles 

-> Et je fais ensuite:
cast send $p "unlock(bytes16)" 0x9e29ae33513b7fd1a85710d0c2f8bc04 --rpc-url 127.0.0.1:8545 --account anvil
$p correspond à l'adresse du smart contract deployé
->Et maintenant j'ai :
cast storage $p 0 --rpc-url 127.0.0.1:8545
0x0000000000000000000000000000000000000000000000000000000000000000
Donc la valeur de locked est passé a false maintenant

                  OU
pour recupérer les 16 bytes de poids forts on peut faire
➜ bytes32 data = 0x9e29ae33513b7fd1a85710d0c2f8bc0408eeffba89ca290e37c927a652bea8f4
➜ bytes16 result = bytes16(data)
➜ result
Type: bytes16
└ Data: 0x9e29ae33513b7fd1a85710d0c2f8bc0400000000000000000000000000000000

On ne peut pas directement faire :
bytes16 result = bytes16(0x9e29ae33513b7fd1a85710d0c2f8bc0408eeffba89ca290e37c927a652bea8f4)
car ce type de conversion est une conversion explicite et cela génère des erreurs
On doit s'assurer de d'abord assigner la valeur dans une variable de type bytes32
avant d'effectuer l'operation de cast et ce type de conversion est appelé une conversion
implicite car ca ne génère pas une erreur

uint128(uint256(move)) me permet de recuperer les 128 bits de poids faibles

bytes32 data = 0x9e29ae33513b7fd1a85710d0c2f8bc0408eeffba89ca290e37c927a652bea8f4;
➜ bytes32 move = data >> 128
move  donnera 0x000000000000000000000000000000009e29ae33513b7fd1a85710d0c2f8bc04
➜ bytes16 = bytes16(uint128(uint256(move)))
➜ bytes16 result= bytes16(uint128(uint256(move)))
Donc en faisant ca  bytes16(uint128(uint256(move))) pourquoi ca ne recupère pas les 16 bytes de poids forts ici qui represente la suite de 0 et ca recupère les 16 derniers bytes

ChatGPT a dit :
ChatGPT
Le comportement observé dans votre exemple concernant la conversion de bytes32 à bytes16 peut être clarifié en comprenant comment chaque opération de conversion et de manipulation fonctionne. Concentrons-nous sur la suite de transformations que vous avez décrite :

Contexte et question :
Entrée initiale :

bytes32 data = 0x9e29ae33513b7fd1a85710d0c2f8bc0408eeffba89ca290e37c927a652bea8f4
Décalage : bytes32 move = data >> 128
Conversion : bytes16 result = bytes16(uint128(uint256(move)))
Problème :

Pourquoi le résultat final contient les 16 bytes de poids faibles au lieu des 16 bytes de poids forts qui devraient être majoritairement des 0 après le décalage de 128 bits ?
Étape 1 : Décalage de 128 bits (data >> 128)
Lorsqu'un décalage de bits est effectué en Solidity :

Les bits de poids faibles sont "décalés hors" (perdus).
Les bits de poids forts sont remplis par des 0 (logique de décalage à droite).
Ainsi :

solidity
Copier le code
bytes32 data = 0x9e29ae33513b7fd1a85710d0c2f8bc0408eeffba89ca290e37c927a652bea8f4;
bytes32 move = data >> 128;
Après décalage, move devient :

plaintext
Copier le code
0x000000000000000000000000000000009e29ae33513b7fd1a85710d0c2f8bc04
Les 128 bits de poids faibles (16 bytes à droite) sont conservés, et les 128 bits de poids forts (à gauche) sont remplis par des 0.

Étape 2 : Conversion avec bytes16(uint128(uint256(move)))
Voici la logique de chaque conversion appliquée à move :

uint256(move) :

La valeur move est interprétée comme un entier non signé de 256 bits.
Aucun changement de valeur : le contenu binaire reste identique.
Résultat intermédiaire :

plaintext
Copier le code
uint256(move) = 0x000000000000000000000000000000009e29ae33513b7fd1a85710d0c2f8bc04
uint128(uint256(move)) :

Cette opération "tronque" la valeur pour ne conserver que les 128 bits de poids faibles (16 bytes de droite).
Les 128 bits de poids forts (à gauche) sont ignorés.
Résultat intermédiaire :

plaintext
Copier le code
uint128(uint256(move)) = 0x9e29ae33513b7fd1a85710d0c2f8bc04
bytes16(uint128(...)) :

Cette opération interprète les 128 bits résultants comme un type bytes16.
Aucun changement de valeur n'est appliqué, juste une conversion de type.
Résultat final :

plaintext
Copier le code
result = 0x9e29ae33513b7fd1a85710d0c2f8bc04
*/
