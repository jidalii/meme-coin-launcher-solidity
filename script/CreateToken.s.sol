// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

import "./MemeXDay.sol";

contract CreateTokenScript is Script, MemeXDay {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        string[3] memory urls_ = ["twitterXi", "tgXi", "websiteXi"];
        IMemexGame.TokenCreation memory tc_ =
            IMemexGame.TokenCreation({name: "Xi", ticker: "XI", desc: "token xi", img: "img://xi", urls: urls_});

        memexGame.createToken{value: 0.1 ether}(tc_);

        vm.stopBroadcast();
    }
}
