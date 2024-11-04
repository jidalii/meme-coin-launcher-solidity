// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

import "../MemeXDay.sol";

contract ManagerScript is Script, MemeXDay {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        setOperator();

        // factory.setFeeTo(address(memexGame));

        vm.stopBroadcast();
    }

    function setOperator() public {
        memexGame.setOperator(address(0xA8E2E17fB824ea1eE8eDc1D45c20d94800669b81), true);
        memexGame.setOperator(address(0x9035417DFF05753D6934cfe6370F549df38F2aCA), true);
        memexGame.setOperator(address(gov), true);
    }
}
