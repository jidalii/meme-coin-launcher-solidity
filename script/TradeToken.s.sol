// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

import "./MemeXDay.sol";

import "../src/token/ERC20.sol";

contract TradeScript is Script, MemeXDay {
    address private _token = address(0x8f0a68E46EAfa5979E729ed96b71498ce2B01f34);
    address private _user = address(0x221bA23331E5395F2018eDafc2E0E9fF2Acb1aDa);

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // uint256 amount = 1 ether;
        // buyToken(_token, amount, _user);

        uint256 tokenAmount = IERC20(_token).balanceOf(_user);
        sellToken(_token, _user, tokenAmount, _user);

        vm.stopBroadcast();
    }

    function buyToken(address token, uint256 amount, address to) private {
        memexGame.presaleBuyTokens{value: amount}(token, to);
    }

    function sellToken(address token, address from, uint256 amount, address to) private {
        uint256 balance = ERC20(token).balanceOf(from);
        ERC20(token).approve(address(router), balance);

        memexGame.presaleSellTokens(amount, token, to);
    }
}
