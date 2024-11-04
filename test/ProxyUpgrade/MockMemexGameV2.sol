// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import "../../src/core/DexLauncherV2.sol";
import "../../src/core/DexLauncherV3.sol";
import "../../src/core/Factory.sol";
import "../../src/core/Router.sol";
import "../../src/core/interfaces/IMemexGame.sol";

contract MockMemexGameV2 is Initializable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    uint256 public constant BASIS_POINTS_DIVISOR = 10000;
    address public constant WGAS = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address public constant UNI_V3_POS = address(0x7b8A01B39D58278b5DE7e48c8449c9f4F5170613);

    // Game
    uint40 public constant minKnockoutDuration = 10 minutes;
    uint40 public constant maxKnockoutDuration = 7 days;
    uint40 public constant minFinalPhaseDuration = 10 minutes;
    uint40 public constant maxFinalPhaseDuration = 7 days;
    uint40 public constant minPostGameBuyDuration = 10 minutes;
    uint40 public constant maxPostGameBuyDuration = 30 days;
    uint256 public constant minKnockoutAmount = 1 ether;
    uint256 public constant maxKnockoutAmount = 1000 ether;
    uint256 public constant maxCreateTokenFee = 2 ether;
    uint256 public constant minBlockGapNumber = 10;
    uint256 public constant maxBlockGapNumber = 10000;
    uint256 public constant minLpFeeBp = 10;
    uint256 public constant maxLpFeeBp = 5000;
    uint256 public constant minKnockoutTokenNumber = 3;
    uint256 public constant maxKnockoutTokenNumber = 100;
    uint256 public constant minWinnerLpBp = 0;
    uint256 public constant maxWinnerLpBp = 10000;

    // Fee
    uint256 public launchFee;
    uint256 public tokenMaxTx;

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                         VARIABLES                          *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    Factory private _factory;
    Router private _router;
    DexLauncherV2 private _dexLauncherV2;
    DexLauncherV3 private _dexLauncherV3;

    uint256 public protocolFeeBalance;

    uint48 public gameNumber;
    mapping(address => uint48) public gameNumberForToken;
    mapping(address => address) private _dexPools;
    mapping(address => bool) private _isOperator;

    receive() external payable {}

    function initialize(
        address initialOwner,
        address factory_,
        address router_,
        address dexLauncher_,
        uint64 _version
    )
        public
        reinitializer(_version)
    {
        // Initialize the inherited contracts
        __ReentrancyGuard_init();
        __Ownable_init(initialOwner);

        // Initialize the state variables
        if (factory_ == address(0)) {
            revert();
        }
        if (router_ == address(0)) {
            revert();
        }
        if (dexLauncher_ == address(0)) {
            revert();
        }

        _factory = Factory(factory_);
        _router = Router(router_);
        _dexLauncherV2 = DexLauncherV2(payable(dexLauncher_));

        launchFee = 6 ether;
        // tokenMaxTx = 0;
    }

    function setTokenMaxTx(uint256 _tokenMaxTx) external {
        tokenMaxTx = _tokenMaxTx;
    }

    function getVersion() external pure returns (uint40) {
        return 2;
    }

    function hello() external pure returns (string memory) {
        return "hello";
    }
}
