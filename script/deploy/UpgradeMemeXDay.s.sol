// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Script, console} from "forge-std/Script.sol";

import "../../src/core/MemexGame.sol";

import "../../src/proxy/MemeXProxy.sol";
import "./../MemeXDay.sol";

contract UpgradeMemeXDayScript is Script, MemeXDay {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MemexGame newMemeXDay = new MemexGame();

        MemeXProxy proxy = MemeXProxy(payable(address(memexGame)));
        bytes memory data = abi.encodeWithSelector(
            MemexGame.initialize.selector, gov, address(factory), address(router), address(dexLauncher), 2
        );

        ProxyAdmin(proxy.proxyAdmin()).upgradeAndCall(
            ITransparentUpgradeableProxy(address(proxy)), address(newMemeXDay), data
        );

        vm.stopBroadcast();
    }
}
