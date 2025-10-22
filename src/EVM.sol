// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EVM {
    uint32 val1;
    uint32 val2;
    uint64 val3;
    uint128 val4;

    function store() public {
        val1 = 1;
        val2 = 2;
        val3 = 3;
        val4 = 4;
    }
}
/* En associant les differentes variables on voit que 32 + 32 + 64 + 128 = 256 
   donc ces variables sont toutes logées dans le slot 0
   Pour recuperer la valeur de val1 , on peut faire
   cast storage $e 0
0x0000000000000000000000000000000400000000000000030000000200000001
ou $e est l'adresse du contrat
et 0x0000000000000000000000000000000400000000000000030000000200000001 sont les différentes valeurs
Pour recuperer les différentes valeurs je puex faire
dakdak@dakdak:~/code/BLOCKCHAIN SECURITY/CTF$ cast storage $e 0
0x0000000000000000000000000000000400000000000000030000000200000001
dakdak@dakdak:~/code/BLOCKCHAIN SECURITY/CTF$ chisel
Welcome to Chisel! Type `!help` to show available commands.
➜ bytes32 p = 0x0000000000000000000000000000000400000000000000030000000200000001
➜ uint256 z = uint256(p)
➜ uint32 val1 = uint32(z) 
➜ val1
Type: uint32
├ Hex: 0x
├ Hex (full word): 0x1
└ Decimal: 1
➜ uint32 val2 = uint32(uint64(z) >> 32)
➜ val2
Type: uint32
├ Hex: 0x
├ Hex (full word): 0x2
└ Decimal: 2
➜ uint64 val3 = uint64(uint128(z) >> 64)
➜ val3
Type: uint64
├ Hex: 0x
├ Hex (full word): 0x3
└ Decimal: 3
➜ uint128 val4 = uint128(z >> 128)
➜ val4
Type: uint128
├ Hex: 0x
├ Hex (full word): 0x4
└ Decimal: 4
   */

//0b0000000000000000001111111111111111
//0b1000000000000000000000000000000001
