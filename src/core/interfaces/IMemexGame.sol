// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IMemexGame {
    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                          STRUCTS                           *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    struct GameConfig {
        // time
        uint40 finalPhaseDuration;
        uint40 knockoutPhraseDuration;
        uint40 blockGapNumber;
        // amount
        uint256 knockoutTokenNumber;
        uint256 knockoutGoalAmount;
        uint256 presaleTotalSupply;
        // fee
        uint256 createTokenFee;
        uint256 winnerLpBp;
        // config
        KnockoutWeight knockoutWeight;
    }

    struct KnockoutWeight {
        uint256 PurchaseWeightBp;
        uint256 VolumeWeightBp;
        uint256 MCWeightBp;
    }

    struct GameState {
        // time
        uint256 phrase1EndBlock;
        uint40 startedAt;
        uint40 knockoutStartAt;
        uint40 finalStartAt;
        uint40 finalizedAt;
        uint40 finalPhaseDuration;
        uint40 knockoutPhraseDuration;
        // token
        address[] tokens;
        address[] knockoutPhraseTokens;
        address[] finalTokens;
        address[] winners;
        mapping(address => bool) isKnockoutToken;
        uint256 liquidityReserve;
        uint256 knockoutGoalAmount;
        KnockoutWeight knockoutWeight;
    }

    struct Data {
        address token;
        string name;
        string ticker;
        uint256 supply;
        uint256 price;
        uint256 marketCap;
        uint256 liquidity;
        uint256 _liquidity;
        uint256 volume;
        uint256 volume24H;
        uint256 prevPrice;
        uint256 lastUpdated;
        uint256 purchaseNumber;
    }

    struct Token {
        address creator;
        address token;
        address pair;
        Data data;
        bool trading;
        bool tradingOnDex;
    }

    struct TokenCreation {
        string name;
        string ticker;
        string desc;
        string img;
        string[3] urls;
    }

    struct TokenInfo {
        mapping(address => Token) info;
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                           EVENTS                           *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    event FeeWithdrawal(uint256 amount, address to);

    // ******************** Config ********************

    event LaunchFeeUpdated(uint256 luanchFee);

    event TokenMaxTxUpdated(uint256 tokenMaxTx);

    event MemexDayInitialized(address factory, address router, address dexLauncher);

    event GameConfigUpdated(GameConfig config);

    // ******************** Game Phrase ********************

    event GameStarted(uint48 indexed gameNumber);

    event Phrase1Ended(uint48 indexed gameNumber, uint256 blockNumber);

    event FinalPhraseStarted(uint48 indexed gameNumnber, address[] finalTokens);

    event GameFinalized(
        uint48 indexed gameNumber,
        address indexed highestPriceToken,
        address indexed lowestPriceToken,
        uint256 highestTokenPrice,
        uint256 lowestTokenPrice,
        uint256 highestLiquidityReward,
        uint256 lowestLiquidityReward,
        uint256 prizePoolFee
    );

    event TokenEnteredKnockout(uint48 indexed gameNumber, address indexed token, uint256 remainingSeats);

    event KnockoutPairing(
        uint48 indexed gameNumber, uint8 groupNumber, address token1, address token2, address token3, address token4
    );

    event TokenEnteredTop4(
        uint48 indexed gameNumber,
        address winner,
        uint256 score,
        uint256 price,
        uint256 marketCap,
        uint256 liquidity,
        uint256 volume
    );

    event V2PoolLaunched(
        uint256 indexed gameNumber, address tk, address poolAddress, uint256 amount0, uint256 amount1, uint256 liquidity
    );

    event V3PoolLaunched(
        uint256 indexed gameNumber,
        address tk,
        address poolAddress,
        uint256 tokenId,
        address tk0,
        uint256 amount0,
        address tk1,
        uint256 amount1,
        uint256 liquidity
    );

    // ******************** Token Creation and Trade ********************

    event TokenCreated(
        uint48 indexed gameNumber,
        address indexed token,
        address indexed creator,
        address pair,
        string name,
        string ticker,
        string image,
        string description,
        string twitter,
        string telegram,
        string website
    );

    event Presale(
        uint48 indexed gameNumber,
        address indexed token,
        address indexed from,
        address to,
        bool isMint,
        uint256 tokenAmount,
        uint256 ethAmount
    );

    event TokenInfoUpdated(
        address indexed token, address indexed pair, uint256 price, uint256 marketCap, uint256 liquidity, uint256 volume
    );

    // ******************** Holder ********************

    event HolderPosition(address indexed owner, address indexed token, uint256 indexed value);

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                           ERRORS                           *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//
    error BlockGapNumberTooHigh();
    error BlockGapNumberTooLow();
    error BuyTooLow();
    error CannotBuyInactiveGame();
    error CannotBuyToZeroAddress();
    error CannotCreateTokenWithAlreadyRaisedFunds();
    error CannotEnterFinalPhraseYet();
    error CannotFinalizeYet();
    error CreateTokenFeeTooHigh();
    error DexPoolAlreadyExisted();
    error TokenPoolNotFound();
    error FinalPhraseAlreadyStarted();
    error FinalPhaseDurationTooLong();
    error FinalPhaseDurationTooShort();
    error GameAlreadyFinalized();
    error GameIsNotOver();
    error GameNotFinalized();
    error InsufficientAmount();
    error InsufficientBalance();
    error InsufficientBlockGap();
    error InsufficientKnockoutTokens(uint256 number);
    error InvalidGame();
    error InvalidGameNumber();
    error KnockoutGoalAmountTooHigh();
    error KnockoutGoalAmountTooLow();
    error KnockoutTokenNumberTooHigh();
    error KnockoutTokenNumberTooLow();
    error LpFeeBpTooHigh();
    error LpFeeBpTooLow();
    error MustBurnSomething();
    error NoGameRunning();
    error NotWinners();
    error ReachSupplyLimit();
    error TokenAlreadyInGame();
    error TokenCreationEnded();
    error TokenDoesNotExist();
    error TokenNotTradable();
    error WinnerLpBpTooHigh();
    error WinnerLpBpTooLow();
    error ZeroAddress();

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                         FUNCTIONS                          *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    // ******************** [Auth]: Fee ********************

    function setLaunchFee(uint56 _launchFee) external;

    function setTokenMaxTx(uint56 _tokenMaxTx) external;

    // ******************** [Auth]: Game Config ********************

    function setGameConfig(GameConfig calldata newConfig) external;

    function gameConfig() external view returns (GameConfig memory);

    // ******************** [Auth]: Reserves ********************

    function liquidityReserves(uint40 _gameNumber) external view returns (uint256);

    function withdrawFees(uint256 amount, address to) external returns (bool);

    // ******************** [Game Phrase] ********************

    function startGame() external;

    function randomizeKnockoutPairing() external;

    function enterFinalPhrase() external;

    function finalizeGame() external;

    // ******************** [Getter]: Token ********************

    function allTokens(uint48 _gameNumber) external view returns (address[] memory);

    function knockoutTokens(uint48 _gameNumber) external view returns (address[] memory);

    function finalTokens(uint48 _gameNumber) external view returns (address[] memory);

    function winners(uint48 _gameNumber) external view returns (address[] memory);

    // ******************** [Getter]: Others ********************

    function pool(address token) external view returns (address);

    // ******************** [Token]: Creation ********************

    function createToken(TokenCreation memory tokenCreation) external payable returns (address, address, uint256);

    // ******************** [Token]: Trade ********************

    function presaleSellTokens(uint256 amountIn, address tk, address to) external returns (bool);

    function presaleBuyTokens(address tk, address to) external payable returns (bool);

    // ******************** [Token]: Launch ********************

    function launchPoolV3(
        address tk,
        int24 poolTick_,
        int24 tickLower_,
        int24 tickHigher_,
        uint256 minTkAmount,
        uint256 minGasAmount
    )
        external
        payable;
}
