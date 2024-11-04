// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "forge-std/console.sol";

import "../ICheatCodes.sol";
import "../TestHelper.sol";
import "./MockMemexGameV1.sol";
import "./MockMemexGameV2.sol";

contract ProxyUpgradeTest is TestHelper {
    function setUp() public {
        _deployMemexDay();
        _setMemexOperator();
        _setRouterOperator();
        vm.prank(gov);
        factory.setRouter(address(router));
        _configMemexGame();
    }

    function test_ProxyUpgrade() public {
        vm.deal(gov, 10 ether);
        vm.startPrank(gov);
        MemexGame newMemeXDay = new MemexGame();

        MemeXProxy proxy = MemeXProxy(payable(address(memexGame)));
        bytes memory data = abi.encodeWithSelector(
            MemexGame.initialize.selector, gov, address(factory), address(router), address(dexLauncher), 2
        );

        ProxyAdmin(proxy.proxyAdmin()).upgradeAndCall(
            ITransparentUpgradeableProxy(address(proxy)), address(newMemeXDay), data
        );

        vm.stopPrank();
    }

    function test_InvalidAccessUpgrade() public {
        vm.deal(gov, 10 ether);
        vm.startPrank(gov);
        MemexGame newMemeXDay = new MemexGame();

        MemeXProxy proxy = MemeXProxy(payable(address(memexGame)));
        bytes memory data = abi.encodeWithSelector(
            MemexGame.initialize.selector, gov, address(factory), address(router), address(dexLauncher), 2
        );

        vm.stopPrank();

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
        vm.prank(user1);
        ProxyAdmin(proxy.proxyAdmin()).upgradeAndCall(
            ITransparentUpgradeableProxy(address(proxy)), address(newMemeXDay), data
        );
    }

    function test_UpgradeToV2() public {
        vm.startPrank(gov);

        // version 1
        MockMemexGameV1 gameV1 = new MockMemexGameV1();

        bytes memory data = abi.encodeWithSelector(
            MockMemexGameV1.initialize.selector, gov, address(factory), address(router), address(dexLauncher), 1
        );
        MemeXProxy proxy = new MemeXProxy(address(gameV1), gov, data);
        MockMemexGameV1 proxyV1Game = MockMemexGameV1(payable(address(proxy)));

        vm.assertEq(proxyV1Game.launchFee(), 0);

        proxyV1Game.setTokenMaxTx(100);

        // version 2
        MockMemexGameV2 gameV2 = new MockMemexGameV2();

        data = abi.encodeWithSelector(
            MemexGame.initialize.selector, gov, address(factory), address(router), address(dexLauncher), 2
        );

        ProxyAdmin(proxy.proxyAdmin()).upgradeAndCall(
            ITransparentUpgradeableProxy(address(proxy)), address(gameV2), data
        );

        MockMemexGameV2 proxyV2Game = MockMemexGameV2(payable(address(proxy)));
        vm.assertEq(proxyV2Game.launchFee(), 6 ether);
        vm.assertEq(proxyV2Game.hello(), "hello");
        vm.assertEq(proxyV2Game.tokenMaxTx(), 100);

        vm.stopPrank();
    }
}
