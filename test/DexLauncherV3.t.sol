// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./ICheatCodes.sol";

import "../src/core/DexLauncherV3.sol";
import "../src/core/interfaces/IDexLauncherV3.sol";
import "../src/token/ERC20.sol";

import {Swap} from "./MockUniswapV3Swap.sol";

contract DexLauncherV3Test is Test {
    // string internal BSC_MAINNET_PRC = "https://public.stackup.sh/api/v1/node/bsc-mainnet";
    string internal BSC_MAINNET_PRC = "https://bsc-rpc.publicnode.com";

    address private wgas = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    address private uniswapV3Factory = address(0xdB1d10011AD0Ff90774D0C6Bb92e5C5c8b4461F7);
    address private uniswapPositionManager = address(0x7b8A01B39D58278b5DE7e48c8449c9f4F5170613);

    DexLauncherV3 private dexLauncher;

    ERC20 private token;

    address gov = address(1);
    address operator1 = address(2);
    address user1 = address(10);

    function setUp() public {
        uint256 forkId = vm.createFork(BSC_MAINNET_PRC);
        vm.selectFork(forkId);

        console.log("in BSC mainnet");

        vm.startPrank(gov);
        token = new ERC20("tk1", "tk1", 0);
        dexLauncher = new DexLauncherV3(uniswapV3Factory, uniswapPositionManager, wgas, -181339, -177284, -179108);

        dexLauncher.setOperator(gov, true);
        dexLauncher.setOperator(operator1, true);
        vm.stopPrank();
    }

    function test_TokenLaunch() public {
        // vm.skip(true);
        uint256 tkAmount = 600_000_000 ether;
        uint256 wgasAmount = 10 ether;

        vm.roll(1);
        vm.deal(operator1, wgasAmount);
        vm.prank(gov);
        token.transfer(operator1, tkAmount);
        console.log("----------before launch----------");
        console.log("operator eth balance: %d", operator1.balance);
        console.log("operator token balance: %d", token.balanceOf(operator1));

        vm.startPrank(operator1);

        vm.roll(2);
        token.approve(address(dexLauncher), tkAmount);

        vm.roll(3);
        (uint256 tokenId, address pool, uint128 liquidity,, uint256 amount0,, uint256 amount1) =
            dexLauncher.createAndMintLiquidity{value: wgasAmount}(address(token), tkAmount, 0, 0);

        vm.stopPrank();

        console.log("----------after launch----------");
        console.log("token balance:");
        console.log("\toperator:", token.balanceOf(operator1));
        console.log("\tdexlauncher: %d", token.balanceOf(address(dexLauncher)));
        console.log("eth balance:");
        console.log("\toperator eth balance:", operator1.balance);
        console.log("\tdexlauncher eth balance: %s", address(dexLauncher).balance);
        console.log("weth balance:");
        console.log("\toperator weth balance:", ERC20(wgas).balanceOf(operator1));
        console.log("\tdexlauncher weth balance: %s", ERC20(wgas).balanceOf(address(dexLauncher)));
        console.log("pool info:");
        console.log("\ttokenId: %s", tokenId);
        console.log("\tpool balance: %d", token.balanceOf(pool));
        console.log("\tliquidity: %s", liquidity);
        console.log("\ttoken amount: %d", amount0);
        console.log("\teth amount: %d", amount1);
    }

    function test_CollectFees() public {
        // vm.skip(true);
        uint256 tkAmount = 600_000_000 ether;
        uint256 wgasAmount = 10 ether;

        vm.roll(block.number + 1);
        vm.deal(operator1, wgasAmount);
        vm.prank(gov);
        token.transfer(operator1, tkAmount);

        vm.startPrank(operator1);

        vm.roll(block.number + 1);
        token.approve(address(dexLauncher), tkAmount);

        vm.roll(block.number + 1);
        (uint256 tokenId,,,,,,) = dexLauncher.createAndMintLiquidity{value: wgasAmount}(address(token), tkAmount, 0, 0);
        vm.stopPrank();

        Swap _swap = new Swap(wgas, address(token));

        // swap GAS for token
        vm.deal(user1, 100 ether);
        vm.prank(user1);
        _swap.swapETHForTokens{value: 10 ether}();

        // swap token for GAS
        vm.prank(gov);
        token.transfer(user1, 100_000 ether);
        vm.prank(user1);
        token.approve(address(_swap), 100_000 ether);
        vm.prank(user1);
        _swap.swapTokenForETH(100_000 ether);

        vm.startPrank(operator1);
        IERC721(0x7b8A01B39D58278b5DE7e48c8449c9f4F5170613).approve(address(dexLauncher), tokenId);

        (address tk0, uint256 amount0, address tk1, uint256 amount1) = dexLauncher.collectAllFees(address(token));
        vm.stopPrank();

        console.log("tk0: %s", tk0);
        console.log("amount0: %d", amount0);
        console.log("tk1: %s", tk1);
        console.log("amount1: %d", amount1);
    }

    function _acquireTokenFromRich(address _token, uint256 _amount, address _receiver, address _rich) internal {
        vm.prank(_rich);
        IERC20(_token).transfer(_receiver, _amount);
    }

    function tradeUniswapV3Pair(address pair) internal {}
}
