// SPDX-License-Identifier: SEE LICENSE IN LICENSE
//Deployé le smart contract a partir du bytecode
pragma solidity ^0.8.18;
import {Script, console} from "forge-std/Script.sol";

contract HuffDeploy is Script {
    function run() public returns (address) {
        //bytecode obtenu en compilant le fichier Solver.huff avec la commande
        //huffc src/Solver/Solver.huff -b
        bytes memory bytecode = hex"60088060093d393df3602a5f5260205ff3";
        address addr;
        vm.startBroadcast();
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        vm.stopBroadcast();
        require(addr != address(0), "erreur lors du deploiement");
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        console.log("address is ", addr);
        console.log("size is ", size);
        return addr;
    }
}
