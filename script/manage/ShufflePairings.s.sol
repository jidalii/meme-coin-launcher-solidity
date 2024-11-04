// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

import "../MemeXDay.sol";

contract ShufflePairingScript is Script, MemeXDay {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        memexGame.randomizeKnockoutPairing();

        vm.stopBroadcast();
    }
}
