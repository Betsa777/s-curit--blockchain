// L'objectif de ce niveau est de pirater le contrat DEX de base ci-dessous et de voler les fonds par manipulation des prix.

// Vous commencerez avec 10 jetons de token1et 10 de token2. Le contrat DEX démarre avec 100 de chaque jeton.

// Vous réussirez à ce niveau si vous parvenez à drainer au moins 1 des 2 jetons du contrat et à permettre au contrat de
// signaler un « mauvais » prix des actifs.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Dex is Ownable {
    address public token1;
    address public token2;

    constructor() Ownable(msg.sender) {}

    function setTokens(address _token1, address _token2) public onlyOwner {
        token1 = _token1;
        token2 = _token2;
    }

    function addLiquidity(
        address token_address,
        uint256 amount
    ) public onlyOwner {
        IERC20(token_address).transferFrom(msg.sender, address(this), amount);
    }

    function swap(address from, address to, uint256 amount) public {
        require(
            (from == token1 && to == token2) ||
                (from == token2 && to == token1),
            "Invalid tokens"
        );
        require(
            IERC20(from).balanceOf(msg.sender) >= amount,
            "Not enough to swap"
        );
        uint256 swapAmount = getSwapPrice(from, to, amount);
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).approve(address(this), swapAmount);
        IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
    }

    function encode(uint112 y) public pure returns (uint224) {
        return uint224(y) * (2 ** 112);
    }

    function uqDiv(uint224 x, uint112 y) public pure returns (uint224 z) {
        z = x / uint224(y);
    }

    function getSwapPrice(
        address from,
        address to,
        uint256 amount
    ) public view returns (uint224) {
        uint224 numerator = encode(
            uint112(amount * IERC20(to).balanceOf(address(this)))
        );
        uint224 returnValue = uqDiv(
            numerator,
            uint112(IERC20(from).balanceOf(address(this)))
        );
        return returnValue;
    }

    function approve(address spender, uint256 amount) public {
        SwappableToken(token1).approve(msg.sender, spender, amount);
        SwappableToken(token2).approve(msg.sender, spender, amount);
    }

    function balanceOf(
        address token,
        address account
    ) public view returns (uint256) {
        return IERC20(token).balanceOf(account);
    }
}

contract SwappableToken is ERC20 {
    address private _dex;

    constructor(
        address dexInstance,
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
    }

    function approve(address owner, address spender, uint256 amount) public {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }
}
