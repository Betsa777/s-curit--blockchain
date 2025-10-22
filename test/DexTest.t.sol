// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import "../src/Dex.sol";
import "./mocks/ERC20Mock.sol";

contract DexTest is Test {
    Dex dex;
    ERC20Mock token1;
    ERC20Mock token2;
    address user;
    uint256 userPrivKey;
    address owner = makeAddr("owner");

    function setUp() public {
        (user, userPrivKey) = makeAddrAndKey("user");

        vm.startBroadcast(owner);
        token1 = new ERC20Mock("token1", "tk1");
        token2 = new ERC20Mock("token2", "tk2");
        dex = new Dex();
        token1.mint(user, 10);
        token2.mint(user, 10);

        token1.mint(owner, 100);
        token2.mint(owner, 100);

        dex.setTokens(address(token1), address(token2));
        vm.stopBroadcast();
    }

    function test_Swap2Token1Gives2Token2BasedOnBalanceAbove() public {
        address _token1 = address(token1);
        address _token2 = address(token2);
        vm.prank(owner);
        token1.approve(address(dex), 100);
        vm.prank(owner);
        token2.approve(address(dex), 100);
        vm.startPrank(owner);
        dex.addLiquidity(address(token1), 100);
        dex.addLiquidity(address(token2), 100);
        vm.stopPrank();
        uint256 amountToGetFromSwap = (2 * token2.balanceOf(address(dex))) /
            token1.balanceOf(address(dex));
        vm.startPrank(user);
        token1.approve(address(dex), 2);
        dex.swap(_token1, _token2, 2);
        vm.stopPrank();

        uint256 userBalanceToken1 = token1.balanceOf(user);
        uint256 userBalanceToken2 = token2.balanceOf(user);

        console.log(" amountToGetFromSwap", amountToGetFromSwap);
        console.log("userBalanceToken1", userBalanceToken1);
        console.log("userBalanceToken2", userBalanceToken2);
        console.log(
            "token1.balanceOf(address(dex))",
            token1.balanceOf(address(dex))
        );
        console.log(
            "token2.balanceOf(address(dex))",
            token2.balanceOf(address(dex))
        );
        vm.assertEq(amountToGetFromSwap, 2);
        vm.assertEq(userBalanceToken1, 8);
        vm.assertEq(userBalanceToken2, 12);
        vm.assertEq(token1.balanceOf(address(dex)), 102);
        vm.assertEq(token2.balanceOf(address(dex)), 98);
    }

    function test_CanStealToken() public {
        // address _token1 = address(token1);
        // address _token2 = address(token2);
        // vm.startPrank(owner);
        // token1.approve(address(dex), 100);

        // token2.approve(address(dex), 100);

        // dex.addLiquidity(address(token1), 100);
        // dex.addLiquidity(address(token2), 100);
        // vm.stopPrank();

        // uint256 amountToGetFromSwap = (2 * token2.balanceOf(address(dex))) /
        //     token1.balanceOf(address(dex));
        // vm.startPrank(user);
        // //user fait une manipulation du prix en envoyant 4 jetons a l'adresse dex sans passer
        // //par dex.addLiquidity(token_address, amount);
        // token1.transfer(address(dex), 6); // maintenant la balance de address(this) de token1 est 106
        // token1.approve(address(dex), 2);
        // dex.swap(_token1, _token2, 2); //les tokens obtenus seront maintenant 2 * 106 / 100
        // vm.stopPrank();

        // uint256 userBalanceToken1 = token1.balanceOf(user);
        // uint256 userBalanceToken2 = token2.balanceOf(user);
        uint224 encode = dex.encode(2 * 102);
        uint224 uqDiv = dex.uqDiv(encode, 100);
        uint112 denominator = uint112(uqDiv);
        uint112 numerator = uint112(uqDiv >> 112);
        console.log("denominator", denominator);
        console.log("numerator", numerator);
    }
}
