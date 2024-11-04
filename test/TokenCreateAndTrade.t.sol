// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "forge-std/console.sol";

import "./ICheatCodes.sol";
import "./TestHelper.sol";

contract TokenCreateAndTradeTest is TestHelper {
    function setUp() public {
        _deployMemexDay();
        _setMemexOperator();
        _setRouterOperator();
        vm.prank(gov);
        factory.setRouter(address(router));
        _configMemexGame();
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                         START GAME                         *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function test_StartGame() public {
        vm.expectEmit(address(memexGame));

        emit IMemexGame.GameStarted(uint48(1));
        vm.prank(gov);
        memexGame.startGame();
    }

    function test_SingleGameAtOnce() public {
        vm.expectEmit(address(memexGame));

        emit IMemexGame.GameStarted(uint48(1));
        vm.prank(gov);
        memexGame.startGame();

        vm.roll(1);

        vm.expectRevert(IMemexGame.GameNotFinalized.selector);
        vm.prank(gov);
        memexGame.startGame();
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                         CREATE TOKEN                       *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function test_CreateToken() public {
        vm.prank(gov);
        memexGame.startGame();

        string[3] memory urls_ = ["twitter1", "tg1", "website1"];
        IMemexGame.TokenCreation memory tc_ = IMemexGame.TokenCreation({
            name: "Token1",
            ticker: "tk1",
            desc: "test token 1",
            img: "img://token1",
            urls: urls_
        });

        vm.expectEmit(true, true, false, false);
        emit IMemexGame.TokenCreated(
            1,
            address(0xe9057E3499e097C1CD29dC17De9C877Bc0391DBA),
            user1,
            address(0x1507Aa1a509BC153c3Cb4513ac79462854bb16bD),
            tc_.name,
            tc_.ticker,
            tc_.img,
            tc_.desc,
            tc_.urls[0],
            tc_.urls[1],
            tc_.urls[2]
        );

        vm.deal(user1, 1 ether);
        vm.prank(user1);
        (address _token, address _pair, uint256 _tokenNumber) = memexGame.createToken{value: 0.2 ether}(tc_);
        console.log("token address: %s", _token);
        console.log("pair address: %s", _pair);
        console.log("token number: %d", _tokenNumber);
        vm.assertEq(_tokenNumber, 1);

        _logReserves(_pair);
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                           BUY TOKEN                        *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function test_BuyToken() public {
        vm.prank(gov);
        memexGame.startGame();

        vm.deal(user1, 1 ether);
        vm.prank(user1);
        (address _token, address _pair,) = memexGame.createToken{value: 0.2 ether}(token1Config);

        vm.deal(user2, 2 ether);
        vm.prank(user2);
        bool isSuccess = memexGame.presaleBuyTokens{value: 1 ether}(_token, user2);
        vm.assertTrue(isSuccess);

        _logReserves(_pair);

        uint256 tokenBalance = IERC20(_token).balanceOf(user2);
        console.log("tokenBalance: %d", tokenBalance);
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                          SELL TOKEN                        *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function test_SellToken() public {
        vm.prank(gov);
        memexGame.startGame();

        vm.deal(user1, 1 ether);
        vm.prank(user1);
        (address _token, address _pair,) = memexGame.createToken{value: 0.2 ether}(token1Config);

        vm.deal(user2, 2 ether);

        vm.startPrank(user2);

        bool isSuccess = memexGame.presaleBuyTokens{value: 2 ether}(_token, user2);
        vm.assertTrue(isSuccess);

        vm.roll(2);
        uint256 balance = ERC20(_token).balanceOf(user2);
        ERC20(_token).approve(address(router), balance);

        vm.roll(3);
        uint256 amount = balance;
        isSuccess = memexGame.presaleSellTokens(amount, _token, user2);
        vm.stopPrank();
        vm.assertTrue(isSuccess);

        _logReserves(_pair);

        uint256 tokenBalance = IERC20(_token).balanceOf(user2);
        console.log("tokenBalance: %d", tokenBalance);
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                         ENTER KNOCKOUT                     *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function test_EnterKnockout() public {
        vm.prank(gov);
        memexGame.startGame();

        vm.deal(user1, 1 ether);
        vm.prank(user1);
        (address _token, address _pair,) = memexGame.createToken{value: 0.2 ether}(token1Config);

        vm.deal(user2, 20 ether);

        vm.expectEmit(true, true, false, true);
        emit IMemexGame.TokenEnteredKnockout(1, _token, 15);

        vm.prank(user2);
        bool isSuccess = memexGame.presaleBuyTokens{value: 11 ether}(_token, user2);
        vm.assertTrue(isSuccess);

        _logReserves(_pair);

        uint256 tokenBalance = IERC20(_token).balanceOf(user2);
        console.log("tokenBalance: %d", tokenBalance);
    }
}
