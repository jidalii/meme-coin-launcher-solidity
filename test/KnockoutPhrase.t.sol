// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/core/interfaces/IMemexGame.sol";
import "./ICheatCodes.sol";
import "./TestHelper.sol";

contract KnockoutPhraseTest is TestHelper {
    function setUp() public {
        _deployMemexDay();
        _setMemexOperator();
        _setRouterOperator();
        vm.prank(gov);
        factory.setRouter(address(router));
        _configMemexGame();
    }

    function test_Phrase1Ended() public {
        vm.prank(gov);
        memexGame.startGame();
        vm.roll(1);

        _createAndHaveSixteenTokensInKnockout();
    }

    function test_KnockoutPairing() public {
        vm.prank(gov);
        memexGame.startGame();
        vm.roll(1);

        _createAndHaveSixteenTokensInKnockout();

        address[] memory tokensBeforeShuffle = memexGame.knockoutTokens(1);
        console.log("********** tokensBeforeShuffle **********");
        for (uint256 i = 0; i < 16; i++) {
            console.log("\t%s", tokensBeforeShuffle[i]);
        }
        console.log();

        vm.roll(block.number + 10 + customizedGameConfig.blockGapNumber);
        vm.prank(operator1);
        memexGame.randomizeKnockoutPairing();
        address[] memory tokensAfterShuffle = memexGame.knockoutTokens(1);

        console.log("********** tokensAfterShuffle **********");
        for (uint256 i = 0; i < 16; i += 4) {
            console.log("group %d:", i / 4);
            console.log("\t%s", tokensAfterShuffle[i]);
            console.log("\t%s", tokensAfterShuffle[i + 1]);
            console.log("\t%s", tokensAfterShuffle[i + 2]);
            console.log("\t%s", tokensAfterShuffle[i + 3]);
        }
    }

    function test_InsufficientBlockGapForRandomPairingInKnockoutPhrase() public {
        vm.prank(gov);
        memexGame.startGame();
        vm.roll(1);

        _createAndHaveSixteenTokensInKnockout();

        vm.roll(block.number + customizedGameConfig.blockGapNumber - 1);
        vm.expectRevert(IMemexGame.InsufficientBlockGap.selector);
        vm.prank(operator1);
        memexGame.randomizeKnockoutPairing();
    }

    function test_KnockoutSnapshot() public {
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

        vm.expectEmit(true, false, false, true);
        emit IMemexGame.FinalPhraseStarted(1, top4Tokens);

        vm.prank(operator1);
        memexGame.enterFinalPhrase();

        console.log("memex balance: %d", address(memexGame).balance);
    }

    function test_TooEarlyEndKnockoutSnapshot() public {
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

        vm.roll(knockoutEndBlock - 1);
        vm.warp(knockoutEndTs - 1);

        vm.expectRevert(IMemexGame.CannotEnterFinalPhraseYet.selector);

        vm.prank(operator1);
        memexGame.enterFinalPhrase();
    }

    function test_AlreadyEndKnockoutSnapshot() public {
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
    }

    function test_EnterFinalBeforeKnockoutStart() public {
        vm.prank(gov);
        memexGame.startGame();
        vm.roll(1);

        _createAndHaveSixteenTokensInKnockout();

        vm.expectRevert(IMemexGame.CannotEnterFinalPhraseYet.selector);
        vm.prank(gov);
        memexGame.enterFinalPhrase();
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
}
