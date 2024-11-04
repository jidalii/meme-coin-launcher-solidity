// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/core/interfaces/IMemexGame.sol";

import "./ICheatCodes.sol";
import {Swap} from "./MockUniswapV3Swap.sol";
import "./TestHelper.sol";

contract FinalPhraseTest is TestHelper {
    address private wgas = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    address private uniswapV2Factory = address(0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6);
    address private uniswapV2Router02 = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;

    address private uniswapV3Factory = address(0xdB1d10011AD0Ff90774D0C6Bb92e5C5c8b4461F7);
    address private uniswapPositionManager = address(0x7b8A01B39D58278b5DE7e48c8449c9f4F5170613);

    function setUp() public {
        uint256 forkId = vm.createFork(BSC_MAINNET_PRC);
        vm.selectFork(forkId);
        console.log("in BSC mainnet");

        vm.prank(gov);
        dexLauncher = new DexLauncherV2(uniswapV2Factory, uniswapV2Router02, wgas);
        _deployMemexDay();
        _setMemexOperator();
        _setRouterOperator();
        vm.prank(gov);
        factory.setRouter(address(router));
        vm.prank(gov);
        dexLauncher.setOperator(address(memexGame), true);

        _configMemexGame();
    }

    function test_FinalizeGame() public {
        vm.prank(gov);
        memexGame.startGame();
        vm.roll(1);

        // ********** Phrase 1 Starts **********

        _createAndHaveSixteenTokensInKnockout();

        vm.roll(block.number + 1 + customizedGameConfig.blockGapNumber);
        vm.prank(operator1);
        memexGame.randomizeKnockoutPairing();

        // ********** Knockout Phrase Starts **********

        // buy tokens:
        // the top4 tokens should be index 0, 4, 8, 12
        address[] memory knockoutTokens = memexGame.knockoutTokens(1);
        address[] memory top4Tokens = new address[](4);
        for (uint256 i = 0; i < 16; i += 4) {
            address _token = knockoutTokens[i];
            top4Tokens[i / 4] = knockoutTokens[i];
            _buyTokens(_token, user2, 10 ether, user2);
        }

        vm.roll(100);

        // mine block...
        uint256 knockoutStartTs = vm.getBlockTimestamp();

        uint256 knockoutEndTs = knockoutStartTs + customizedGameConfig.knockoutPhraseDuration;

        uint256 knockoutEndBlock = _getBlockNumberFromTs(knockoutEndTs, block.number, knockoutStartTs);

        // ********** Knockout Phrase Ends **********

        vm.roll(knockoutEndBlock);
        vm.warp(knockoutEndTs);
        vm.prank(operator1);
        memexGame.enterFinalPhrase();

        vm.roll(block.number + 1);
        vm.warp(knockoutEndTs + 10 seconds);
        vm.expectRevert(IMemexGame.FinalPhraseAlreadyStarted.selector);
        vm.prank(operator1);
        memexGame.enterFinalPhrase();

        // knockout -> final phrase

        address[] memory finalTokens_ = memexGame.finalTokens(1);
        console.log("final tokens");
        for (uint256 i = 0; i < 4; i++) {
            console.log(finalTokens_[i]);
        }

        uint256 highestTokenIndex = 1;
        uint256 lowestTokenIndex = 3;

        _tradeTokenDeterministicallyInFinal(finalTokens_, highestTokenIndex, lowestTokenIndex);

        knockoutStartTs = vm.getBlockTimestamp();

        knockoutEndTs = knockoutStartTs + customizedGameConfig.knockoutPhraseDuration;

        vm.warp(knockoutEndTs);

        vm.expectEmit(true, true, true, false);
        emit IMemexGame.GameFinalized(1, finalTokens_[highestTokenIndex], finalTokens_[lowestTokenIndex], 0, 0, 0, 0, 0);

        vm.prank(operator1);
        memexGame.finalizeGame();
    }

    function test_LaunchTokensOnDex() public {
        _startAndFinalizeGame();
        address[] memory winners = memexGame.winners(1);
        vm.roll(block.number + 1);
        vm.prank(operator1);
        memexGame.launchPoolV2(winners[0], 0, 0);
        vm.prank(operator1);
        memexGame.launchPoolV2(winners[1], 0, 0);
    }

    function test_TokenNotTradable() public {
        _startGameAndEnterFinal();

        vm.roll(block.number + 1);
        address[] memory knockoutTokens = memexGame.knockoutTokens(1);
        address[] memory finalTokens = memexGame.finalTokens(1);

        vm.roll(block.number + 1);

        for (uint256 i = 0; i < knockoutTokens.length; i++) {
            if (!_isFinalTokens(knockoutTokens[i])) {
                vm.deal(user1, 1 ether);
                vm.prank(user1);
                vm.expectRevert(IMemexGame.TokenNotTradable.selector);
                memexGame.presaleBuyTokens{value: 1 ether}(knockoutTokens[i], user1);
            }
        }

        _buyTokens(finalTokens[0], user1, 1 ether, user1);
    }

    function test_LaunchTokenAndWithdrawPoolFee() public {
        vm.skip(true);
        _startAndFinalizeGame();
        address[] memory winners = memexGame.winners(1);
        vm.roll(block.number + 1);
        vm.prank(operator1);
        memexGame.launchPoolV3(winners[0], -154593, -156825, -152770, 0, 0);

        // interact with dex pool
        Swap _swap = new Swap(wgas, winners[0]);

        uint256 balance_ = IERC20(winners[0]).balanceOf(user2);
        _sellTokenFromDex(_swap, winners[0], user2, balance_);

        _buyTokenFromDex(_swap, user1, 1000 ether);

        // withdraw dex pool fees
        vm.prank(gov);
        // (address tk0, uint256 amount0, address tk1, uint256 amount1)=memexGame.withdrawDexPoolFees(winners[0]);
        // console.log("with draw fees from dex:");
        // console.log("\ttk0: %s", tk0);
        // console.log("\tamount0: %d", amount0);
        // console.log("\ttk1: %s", tk1);
        // console.log("\tamount1: %d", amount1);
    }

    function _isFinalTokens(address tk) internal view returns (bool isInFinal) {
        address[] memory finalTokens = memexGame.finalTokens(1);
        for (uint256 i = 0; i < finalTokens.length; i++) {
            if (tk == finalTokens[i]) {
                isInFinal = true;
            }
        }
    }

    function _startGameAndEnterFinal() internal {
        vm.prank(gov);
        memexGame.startGame();
        vm.roll(35294157);

        // ********** Phrase 1 Starts **********

        _createAndHaveSixteenTokensInKnockout();

        vm.roll(block.number + 1 + customizedGameConfig.blockGapNumber);
        vm.prank(operator1);
        memexGame.randomizeKnockoutPairing();

        // ********** Knockout Phrase Starts **********

        // buy tokens:
        // the top4 tokens should be index 0, 4, 8, 12
        address[] memory knockoutTokens = memexGame.knockoutTokens(1);
        address[] memory top4Tokens = new address[](4);
        for (uint256 i = 0; i < 16; i += 4) {
            address _token = knockoutTokens[i];
            top4Tokens[i / 4] = knockoutTokens[i];
            _buyTokens(_token, user2, 10 ether, user2);
        }

        vm.roll(100);

        // mine block...
        uint256 knockoutStartTs = vm.getBlockTimestamp();

        uint256 knockoutEndTs = knockoutStartTs + customizedGameConfig.knockoutPhraseDuration;

        uint256 knockoutEndBlock = _getBlockNumberFromTs(knockoutEndTs, block.number, knockoutStartTs);

        // ********** Knockout Phrase Ends **********

        vm.roll(knockoutEndBlock);
        vm.warp(knockoutEndTs);
        vm.prank(operator1);
        memexGame.enterFinalPhrase();
    }

    function _startAndFinalizeGame() internal {
        vm.prank(gov);
        memexGame.startGame();
        vm.roll(35294157);

        // ********** Phrase 1 Starts **********

        _createAndHaveSixteenTokensInKnockout();

        vm.roll(block.number + 1 + customizedGameConfig.blockGapNumber);
        vm.prank(operator1);
        memexGame.randomizeKnockoutPairing();

        // ********** Knockout Phrase Starts **********

        // buy tokens:
        // the top4 tokens should be index 0, 4, 8, 12
        address[] memory knockoutTokens = memexGame.knockoutTokens(1);
        address[] memory top4Tokens = new address[](4);
        for (uint256 i = 0; i < knockoutTokens.length; i += 4) {
            address _token = knockoutTokens[i];
            top4Tokens[i / 4] = knockoutTokens[i];
            _buyTokens(_token, user2, 10 ether, user2);
        }

        vm.roll(100);

        // mine block...
        uint256 knockoutStartTs = vm.getBlockTimestamp();

        uint256 knockoutEndTs = knockoutStartTs + customizedGameConfig.knockoutPhraseDuration;

        uint256 knockoutEndBlock = _getBlockNumberFromTs(knockoutEndTs, block.number, knockoutStartTs);

        // ********** Knockout Phrase Ends **********

        vm.roll(knockoutEndBlock);
        vm.warp(knockoutEndTs);
        vm.prank(operator1);
        memexGame.enterFinalPhrase();

        vm.roll(block.number + 1);
        vm.warp(knockoutEndTs + 10 seconds);
        vm.expectRevert(IMemexGame.FinalPhraseAlreadyStarted.selector);
        vm.prank(operator1);
        memexGame.enterFinalPhrase();

        address[] memory finalTokens_ = memexGame.finalTokens(1);
        console.log("final tokens:");
        for (uint256 i = 0; i < 4; i++) {
            console.log("\t%s", finalTokens_[i]);
        }

        uint256 highestTokenIndex = 1;
        uint256 lowestTokenIndex = 3;

        _tradeTokenDeterministicallyInFinal(finalTokens_, highestTokenIndex, lowestTokenIndex);

        knockoutStartTs = vm.getBlockTimestamp();

        knockoutEndTs = knockoutStartTs + customizedGameConfig.knockoutPhraseDuration;

        vm.warp(knockoutEndTs);

        vm.expectEmit(true, true, true, false);
        emit IMemexGame.GameFinalized(1, finalTokens_[highestTokenIndex], finalTokens_[lowestTokenIndex], 0, 0, 0, 0, 0);

        vm.prank(operator1);
        memexGame.finalizeGame();
    }

    function _createAndHaveSixteenTokensInKnockout() internal {
        for (uint256 i = 0; i < 16; i++) {
            vm.roll(block.number + i + 1);
            vm.deal(user1, 0.2 ether);
            vm.prank(user1);
            (address _token,,) = memexGame.createToken{value: 0.2 ether}(token1Config);

            if (i == 15) {
                vm.expectEmit(false, false, false, true);
                emit IMemexGame.Phrase1Ended(1, block.number);
            }

            vm.expectEmit(true, true, false, true);
            emit IMemexGame.TokenEnteredKnockout(1, _token, uint256(15 - i));

            _buyTokens(_token, user2, 11 ether, user2);
        }
    }

    function _tradeTokenDeterministicallyInFinal(
        address[] memory _finalTokens,
        uint256 _highestIndex,
        uint256 _lowestIndex
    )
        internal
    {
        for (uint256 i = 0; i < _finalTokens.length; i++) {
            if (i == _highestIndex) {
                _buyTokens(_finalTokens[_highestIndex], user2, 10 ether, user2);
            } else if (i == _lowestIndex) {} else {
                _buyTokens(_finalTokens[i], user3, 1 ether, user3);
            }
        }
    }

    function print_array(address[] memory array) public pure {
        for (uint256 i = 0; i < array.length; i++) {
            console.log(array[i]);
        }
    }
}
