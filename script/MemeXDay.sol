// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "../src/core/DexLauncherV2.sol";
import "../src/core/Factory.sol";
import "../src/core/MemexGame.sol";
import "../src/core/Router.sol";

contract MemeXDay {
    // old game
    // Factory factory = Factory(0x3F05810c438E285dBF81516b44f267358eD94430);
    // Router router = Router(0x67fc9BA7E3BE08412405FCdB19Fa63f9C2F11182);
    // MemexGame memexGame = MemexGame(payable(0x6FEF16c7d0c89A57E1F45A6ABd6C4e3C5895623C)); // proxy

    // new game
    Factory factory = Factory(0x5E61747026bA6B0297908742e11141dc9faF2AE1);
    Router router = Router(0x636268BB397f1CEA45A83f9315f6Fd5Ad97F6e7a);
    DexLauncherV2 dexLauncher = DexLauncherV2(payable(0x7a1318cc44556C5216044Ca1288E775ad5F92D38));
    MemexGame memexGame = MemexGame(payable(0x36116821b2C8eE41CC08c3bfD1adF8887a61e060)); // proxy

    address gov = address(0x221bA23331E5395F2018eDafc2E0E9fF2Acb1aDa);
}
