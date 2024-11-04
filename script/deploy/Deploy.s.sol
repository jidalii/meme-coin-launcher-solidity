// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

import "../../src/core/DexLauncherV3.sol";
import "../../src/core/Factory.sol";
import "../../src/core/MemexGame.sol";
import "../../src/core/Pair.sol";
import "../../src/core/Router.sol";

import "../../src/proxy/MemeXProxy.sol";
import "../../src/token/ERC20.sol";

contract DeployScript is Script {
    address public constant WETH_HOLESKY = address(0x94373a4919B3240D86eA41593D5eBa789FEF3848);
    address public constant WETH_NEOX = address(0x1CE16390FD09040486221e912B87551E4e44Ab17);

    address private uniswapV3Factory = address(0xdB1d10011AD0Ff90774D0C6Bb92e5C5c8b4461F7);
    address private uniswapPositionManager = address(0x7b8A01B39D58278b5DE7e48c8449c9f4F5170613);

    uint256 public constant txnFeeBp = 100;

    address gov = address(0x221bA23331E5395F2018eDafc2E0E9fF2Acb1aDa);

    Factory factory;
    Router router;
    MemexGame memexGame;
    MemeXProxy memexProxy;
    DexLauncherV2 dexLauncher;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        deployContracts();

        factory.setRouter(address(router));

        factory.setFeeTo(address(memexGame));

        router.setMaster(address(memexGame));

        factory.setRouter(address(router));

        memexGame.setOperator(gov, true);
        memexGame.setOperator(address(0x9035417DFF05753D6934cfe6370F549df38F2aCA), true);

        vm.stopBroadcast();
    }

    function deployContracts() public {
        factory = new Factory(msg.sender, txnFeeBp);

        router = new Router(address(factory), WETH_NEOX);

        dexLauncher = new DexLauncherV2(uniswapV3Factory, uniswapPositionManager, WETH_NEOX);

        memexGame = new MemexGame();
        bytes memory data = abi.encodeWithSelector(MemexGame.initialize.selector, gov, factory, router, dexLauncher, 1);
        memexProxy = new MemeXProxy(address(memexGame), gov, data);
        memexGame = MemexGame(payable(address(memexProxy)));
    }
}
