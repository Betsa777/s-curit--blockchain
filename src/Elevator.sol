//Cet ascenseur ne vous permettra pas d'atteindre le sommet de votre immeuble. N'est-ce pas ?
//But: Empêcher cet ascenceur de monter a l'étage précisé
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
    bool public top;
    uint256 public floor;

    //Me permet de monter d'une etage grace a l'ascenceur
    function goTo(uint256 _floor) public {
        //Ici msg.sender represente le contract Attack dans le fichier ElevatorTest.t.sol
        //Donc il est supposé que le msg.sender ait implémenté l'interface Building
        //pour qu'il n'yait pas d'erreur
        //Ici pour empêcher l'utilisateur de monter il me suffit de toujours
        //renvoyer true depuis mon contract Attack dans la fonction
        //isLastFloor de la libraire Building pour faire croire que l'utilisateur est dejà arrivé
        //ou il voulait
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}

//Doit implementer l'interface Building pour appeler la fonction goTo
contract Attack is Building {
    function isLastFloor(uint256) external pure override returns (bool) {
        return true;
    }
}
