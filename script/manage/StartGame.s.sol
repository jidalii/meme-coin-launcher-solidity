// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

import "../MemeXDay.sol";

contract StartGameScript is Script, MemeXDay {
    IMemexGame.KnockoutWeight public knockoutWeight =
        IMemexGame.KnockoutWeight({PurchaseWeightBp: 2000, VolumeWeightBp: 3000, MCWeightBp: 5000});
    IMemexGame.GameConfig public customizedGameConfig = IMemexGame.GameConfig({
        finalPhaseDuration: 30 minutes,
        knockoutPhraseDuration: 30 minutes,
        knockoutTokenNumber: 16,
        knockoutGoalAmount: 1 ether,
        presaleTotalSupply: 600_000_000 ether,
        createTokenFee: 0.1 ether,
        blockGapNumber: 10,
        winnerLpBp: 7_000,
        knockoutWeight: knockoutWeight
    });

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        memexGame.setGameConfig(customizedGameConfig);
        memexGame.startGame();

        vm.stopBroadcast();
    }
}
