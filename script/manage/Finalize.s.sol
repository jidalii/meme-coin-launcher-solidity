// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

import "../MemeXDay.sol";

contract FinalizeScript is Script, MemeXDay {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        memexGame.finalizeGame();

        vm.stopBroadcast();
    }
}
