// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

import "../MemeXDay.sol";

contract ReplaceDexLauncherScript is Script, MemeXDay {
    address public constant WETH_HOLESKY = address(0x94373a4919B3240D86eA41593D5eBa789FEF3848);
    address public constant WETH_NEOX = address(0x1CE16390FD09040486221e912B87551E4e44Ab17);

    address private uniswapV3Factory = address(0xdB1d10011AD0Ff90774D0C6Bb92e5C5c8b4461F7);
    address private uniswapPositionManager = address(0x7b8A01B39D58278b5DE7e48c8449c9f4F5170613);

    address private uniswapV2Factory = address(0x1996bbe6e83880caBB23b70dC3BbA236d3b6ECb4);
    address private uniswapV2Router02 = 0xA4e4Cf81944691fbE755eA848e4e40cf9d1A42d1;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        DexLauncherV2 newDexLauncher = new DexLauncherV2(uniswapV2Factory, uniswapV2Router02, WETH_NEOX);
        newDexLauncher.setOperator(address(memexGame),true);

        memexGame.updateDexLauncherV2(address(newDexLauncher));

        vm.stopBroadcast();
    }

}
