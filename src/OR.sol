// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract OR {
    // `|` OU binaire (bitwise OR)
    //effectue un ou au niveau binaire
    function bitwiseOrExample() public pure returns (uint8) {
        uint8 a = 12; //0b1100
        uint8 b = 10; //0b1010
        return a | b; //0b1110 (14 en decimal)
    }

    // `||` OU logique (logical OR)
    //effectue un ou sur des booleans
    function logicalOrExample() public pure returns (bool) {
        bool a = true;
        bool b = false;
        return a || b; //return true
    }

    // `|=` OU binaire avec assignation (bitwise OR assignment)
    function bitwiseOrAssignExample() public pure returns (uint8) {
        uint8 a = 12; // 0b1100 en binaire
        uint8 b = 10; // 0b1010 en binaire
        a |= b; // Équivaut à a = a | b
        return a; // Résultat : 0b1110 (14 en décimal)
    }
}
