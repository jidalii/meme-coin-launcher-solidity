// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/core/interfaces/IMemexGame.sol";
import "./ICheatCodes.sol";

import "../src/core/Factory.sol";
import "../src/core/MemexGame.sol";
import "../src/core/Router.sol";
import "../src/proxy/MemeXProxy.sol";
import {ERC20} from "../src/token/ERC20.sol";
import {Swap} from "./MockUniswapV3Swap.sol";

contract TestHelper is Test {
    CheatCodes cheats = CheatCodes(VM_ADDRESS);

    string internal BSC_MAINNET_PRC = "https://bsc-rpc.publicnode.com";

    ProxyAdmin proxyAdmin;

    Factory factory;
    MemexGame memexGame;
    Router router;
    DexLauncherV2 dexLauncher = DexLauncherV2(payable(address(1000)));

    address constant WETH_BSC = 0x9cB928A44B0664Ad8e933C833f8210d772269b68;
    uint256 public txnFeeBp = 100;

    IMemexGame.KnockoutWeight public knockoutWeight =
        IMemexGame.KnockoutWeight({PurchaseWeightBp: 200, VolumeWeightBp: 300, MCWeightBp: 500});

    IMemexGame.GameConfig public customizedGameConfig = IMemexGame.GameConfig({
        finalPhaseDuration: 48 hours,
        knockoutPhraseDuration: 48 hours,
        knockoutTokenNumber: 16,
        knockoutGoalAmount: 10 ether,
        presaleTotalSupply: 600_000_000 ether,
        createTokenFee: 0.2 ether,
        blockGapNumber: 100,
        winnerLpBp: 7000,
        knockoutWeight: knockoutWeight
    });

    string[3] public urlsToken1 = ["twitter1", "tg1", "website1"];
    IMemexGame.TokenCreation public token1Config = IMemexGame.TokenCreation({
        name: "Token1",
        ticker: "tk1",
        desc: "test token 1",
        img: "img://token1",
        urls: urlsToken1
    });

    address gov = address(4);
    address operator1 = address(5);
    address user1 = address(11);
    address user2 = address(12);
    address user3 = address(13);

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                      DEPLOY AND CONFIG                     *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function _deployMemexDay() internal {
        vm.startPrank(gov);
        factory = new Factory(gov, txnFeeBp);

        router = new Router(address(factory), WETH_BSC);

        memexGame = new MemexGame();

        bytes memory data = abi.encodeWithSelector(
            MemexGame.initialize.selector, gov, address(factory), address(router), address(dexLauncher), 1
        );

        MemeXProxy proxy = new MemeXProxy(address(memexGame), gov, data);

        // Cast the proxy address to the MemexGame type
        memexGame = MemexGame(payable(address(proxy)));
        vm.stopPrank();
    }

    function _configMemexGame() internal {
        vm.startPrank(gov);
        memexGame.setGameConfig(customizedGameConfig);
        vm.stopPrank();
    }

    function _setMemexOperator() internal {
        vm.startPrank(gov);
        memexGame.setOperator(gov, true);
        memexGame.setOperator(operator1, true);
        vm.stopPrank();
    }

    function _setRouterOperator() internal {
        vm.startPrank(gov);
        router.setMaster(address(memexGame));
        vm.stopPrank();
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                        TRADE AND LOG                       *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function _buyTokens(address token, address from, uint256 amount, address to) internal {
        vm.deal(from, amount);
        vm.prank(from);
        bool isSuccess = memexGame.presaleBuyTokens{value: amount}(token, to);
        vm.assertTrue(isSuccess);
    }

    function _sellTokens(address token, address from, uint256 amount, address to) internal {
        vm.prank(from);
        IERC20(token).approve(address(memexGame), amount);
        vm.prank(from);
        bool isSuccess = memexGame.presaleSellTokens(amount, token, to);
        vm.assertTrue(isSuccess);
    }

    function _buyTokenFromDex(Swap _swap, address from, uint256 amountETH) internal {
        vm.deal(from, amountETH);
        vm.prank(from);
        _swap.swapETHForTokens{value: amountETH}();
    }

    function _sellTokenFromDex(Swap _swap, address token, address from, uint256 amount) internal {
        vm.prank(from);
        IERC20(token).approve(address(_swap), amount);
        vm.prank(from);
        _swap.swapTokenForETH(amount);
    }

    function _logReserves(address _pair) internal view {
        (uint256 reserver0, uint256 _reserver0, uint256 reserver1, uint256 _reserver1) =
            Pair(payable(_pair)).getReserves();
        console.log("reserver0: %d", reserver0);
        console.log("_reserver0: %d", _reserver0);
        console.log("reserver1: %d", reserver1);
        console.log("_reserver1: %d", _reserver1);
    }

    function _getBlockNumberFromTs(
        uint256 targetTimestamp,
        uint256 startingBlockNumber,
        uint256 startingTimestamp
    )
        internal
        pure
        returns (uint256)
    {
        uint256 averageBlockTime = 13; // Average block time in seconds
        uint256 blocksSinceStart = (targetTimestamp - startingTimestamp) / averageBlockTime;
        return startingBlockNumber + blocksSinceStart;
    }
}
