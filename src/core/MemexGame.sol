// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "forge-std/console.sol";

import "../token/ERC20.sol";
import "./DexLauncherV2.sol";
import "./DexLauncherV3.sol";
import "./Factory.sol";
import "./Router.sol";
import "./interfaces/IMemexGame.sol";

contract MemexGame is Initializable, IMemexGame, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                          CONFIGS                           *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    uint256 public constant BASIS_POINTS_DIVISOR = 10_000;
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

    GameConfig private _gameConfig;

    Factory private _factory;
    Router private _router;
    DexLauncherV2 private _dexLauncherV2;
    DexLauncherV3 private _dexLauncherV3;

    uint256 public protocolFeeBalance;

    uint48 public gameNumber;
    mapping(uint48 => GameState) private _gameStateForGameNumber;
    mapping(address => uint48) public gameNumberForToken;
    mapping(uint48 => TokenInfo) private _tokenInfoForGameNumber;
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
            revert ZeroAddress();
        }
        if (router_ == address(0)) {
            revert ZeroAddress();
        }
        if (dexLauncher_ == address(0)) {
            revert ZeroAddress();
        }

        _factory = Factory(factory_);
        _router = Router(router_);
        _dexLauncherV2 = DexLauncherV2(payable(dexLauncher_));

        launchFee = 0;
        tokenMaxTx = 0;

        emit MemexDayInitialized(factory_, router_, dexLauncher_);
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                           CONFIG                           *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function updateFactory(address factory_) external onlyOwner {
        _factory = Factory(factory_);
    }

    function updateRouter(address router_) external onlyOwner {
        _router = Router(router_);
    }

    function updateDexLauncherV2(address dexLuancher_) external onlyOwner {
        _dexLauncherV2 = DexLauncherV2(payable(dexLuancher_));
    }

    function updateDexLauncherV3(address dexLuancher_) external onlyOwner {
        _dexLauncherV3 = DexLauncherV3(payable(dexLuancher_));
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                           GETTER                           *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function allTokens(uint48 _gameNumber) external view returns (address[] memory) {
        _validateGameNumber(_gameNumber);
        GameState storage _gameState = _gameStateForGameNumber[_gameNumber];
        return _gameState.tokens;
    }

    function knockoutTokens(uint48 _gameNumber) external view returns (address[] memory) {
        _validateGameNumber(_gameNumber);
        GameState storage _gameState = _gameStateForGameNumber[_gameNumber];
        return _gameState.knockoutPhraseTokens;
    }

    function finalTokens(uint48 _gameNumber) external view returns (address[] memory) {
        _validateGameNumber(_gameNumber);
        GameState storage _gameState = _gameStateForGameNumber[_gameNumber];
        return _gameState.finalTokens;
    }

    function winners(uint48 _gameNumber) external view returns (address[] memory) {
        _validateGameNumber(_gameNumber);
        GameState storage _gameState = _gameStateForGameNumber[_gameNumber];
        return _gameState.winners;
    }

    function pool(address token) external view returns (address) {
        return _dexPools[token];
    }

    function _validateGameNumber(uint48 _gameNumber) private view {
        if (_gameNumber > gameNumber) {
            revert InvalidGameNumber();
        }
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                       FEE AND RESERVE                      *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function setLaunchFee(uint56 _launchFee) external onlyOperator {
        launchFee = _launchFee;
        emit LaunchFeeUpdated(_launchFee);
    }

    function setTokenMaxTx(uint56 _tokenMaxTx) external onlyOperator {
        tokenMaxTx = _tokenMaxTx;
        emit TokenMaxTxUpdated(_tokenMaxTx);
    }

    function liquidityReserves(uint40 _gameNumber) external view returns (uint256) {
        _validateGameNumber(_gameNumber);
        return _gameStateForGameNumber[_gameNumber].liquidityReserve;
    }

    function withdrawFees(uint256 amount, address to) external onlyOwner returns (bool) {
        if (amount > protocolFeeBalance) {
            revert InsufficientBalance();
        }

        (bool os,) = payable(to).call{value: amount}("");
        emit FeeWithdrawal(amount, to);

        return os;
    }

    function withdrawDexPoolFees(address tk)
        external
        onlyOwner
        returns (address tk0, uint256 amount0, address tk1, uint256 amount1)
    {
        // uint256 tokenId = _dexLauncherV2.tokenIdFromToken(tk);
        // IERC721(UNI_V3_POS).approve(address(_dexLauncherV2), tokenId);

        // (tk0, amount0, tk1, amount1) = _dexLauncherV2.collectAllFees(tk);
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                          START GAME                        *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function startGame() external onlyOperator {
        uint48 currentGameNumber = gameNumber;
        if (currentGameNumber != 0 && _gameStateForGameNumber[currentGameNumber].finalizedAt == 0) {
            revert GameNotFinalized();
        }

        unchecked {
            currentGameNumber++;
        }
        gameNumber = currentGameNumber;
        GameState storage _gameState = _gameStateForGameNumber[currentGameNumber];
        _gameState.startedAt = uint40(block.timestamp);
        _gameState.phrase1EndBlock = 0;
        _gameState.knockoutStartAt = 0;
        _gameState.finalStartAt = 0;
        _gameState.finalizedAt = 0;
        _gameState.tokens = new address[](0);
        _gameState.knockoutPhraseTokens = new address[](0);
        _gameState.finalTokens = new address[](0);
        _gameState.winners = new address[](0);
        _gameState.liquidityReserve = 0;
        _gameState.finalPhaseDuration = _gameConfig.finalPhaseDuration;
        _gameState.knockoutPhraseDuration = _gameConfig.knockoutPhraseDuration;
        _gameState.knockoutGoalAmount = _gameConfig.knockoutGoalAmount;
        _gameState.knockoutWeight = _gameConfig.knockoutWeight;

        emit GameStarted(currentGameNumber);
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                   SHUFFLE TOKEN PAIRINGS                   *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function randomizeKnockoutPairing() external onlyOperator nonReentrant {
        // validate knockout paring
        uint256 phrase1EndBlock = _gameStateForGameNumber[gameNumber].phrase1EndBlock;
        uint256 blockGap = _gameConfig.blockGapNumber;

        if (phrase1EndBlock + blockGap >= block.number) {
            revert InsufficientBlockGap();
        }

        uint256 blockNumber = phrase1EndBlock + blockGap;
        bytes32 blockHash = blockhash(blockNumber);
        GameState storage _gameState = _gameStateForGameNumber[gameNumber];
        address[] storage _tokens = _gameState.knockoutPhraseTokens;

        _shuffleAddresses(_tokens, blockNumber, blockHash);

        for (uint256 i = 0; i < _tokens.length; i += 4) {
            emit KnockoutPairing(gameNumber, uint8(i / 4), _tokens[i], _tokens[i + 1], _tokens[i + 2], _tokens[i + 3]);
        }
        _gameState.knockoutStartAt = uint40(block.timestamp);
    }

    function _shuffleAddresses(address[] storage addresses, uint256 blockNumber, bytes32 blockHash) internal {
        for (uint256 i = addresses.length - 1; i > 0; i--) {
            uint256 n = uint256(keccak256(abi.encodePacked(blockHash, blockNumber, i))) % (i + 1);

            // Swap the addresses
            address temp = addresses[i];
            addresses[i] = addresses[n];
            addresses[n] = temp;
        }
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*              KNOCKOUT PHRASE -> FINAL PHRASE               *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function enterFinalPhrase() external onlyOperator {
        GameState storage _gameState = _gameStateForGameNumber[gameNumber];
        _validateStartFinalPhrase(_gameState);

        address[] memory _knockoutTokens = _gameState.knockoutPhraseTokens;

        for (uint8 i = 0; i < _gameConfig.knockoutTokenNumber; i += 4) {
            address[4] memory _addresses;
            _addresses[0] = _knockoutTokens[i];
            _addresses[1] = _knockoutTokens[i + 1];
            _addresses[2] = _knockoutTokens[i + 2];
            _addresses[3] = _knockoutTokens[i + 3];
            _electToFinal(_addresses);
        }

        _gameState.finalStartAt = uint40(block.timestamp);
        emit FinalPhraseStarted(gameNumber, _gameState.finalTokens);
    }

    function _electToFinal(address[4] memory _addresses) private {
        TokenInfo storage tokenInfo = _tokenInfoForGameNumber[gameNumber];

        KnockoutWeight memory _weight = _gameStateForGameNumber[gameNumber].knockoutWeight;

        uint256 maxMC = 0;
        uint256 maxVolume = 0;
        uint256 maxScore = 0;
        uint256 topTokenIndex = 0;
        uint256 length = _addresses.length;

        // find maxMC and maxVolume
        for (uint256 i = 0; i < length; i++) {
            uint256 tempMC = tokenInfo.info[_addresses[i]].data.marketCap;
            uint256 tempVolume = tokenInfo.info[_addresses[i]].data.volume;

            // Find max values
            if (tempMC > maxMC) {
                maxMC = tempMC;
            }
            if (tempVolume > maxVolume) {
                maxVolume = tempVolume;
            }
        }

        // find the top winner based on score
        for (uint256 i = 0; i < length; i++) {
            uint256 tempMC = tokenInfo.info[_addresses[i]].data.marketCap;
            uint256 tempVolume = tokenInfo.info[_addresses[i]].data.volume;
            uint256 tempPurchase = tokenInfo.info[_addresses[i]].data.purchaseNumber;
            uint256 tempScore;
            if (tempPurchase >= 10_000) {
                tempScore += _weight.PurchaseWeightBp * 10_000;
            } else {
                tempScore += _weight.PurchaseWeightBp * BASIS_POINTS_DIVISOR * tempPurchase / 10_000;
            }
            tempScore = _weight.VolumeWeightBp * BASIS_POINTS_DIVISOR * tempVolume / maxVolume
                + _weight.MCWeightBp * BASIS_POINTS_DIVISOR * tempMC / maxMC;

            if (tempScore > maxScore) {
                maxScore = tempScore;
                topTokenIndex = i;
            }
        }

        // Determine the top token based on market cap
        address topToken = _addresses[topTokenIndex];

        GameState storage _gameState = _gameStateForGameNumber[gameNumber];
        for (uint256 i = 0; i < 4; i++) {
            address token = _addresses[i];
            if (token != topToken) {
                _withdrawTokenLiqudity(_gameState, token);
            }
        }
        _gameState.finalTokens.push(topToken);

        {
            uint256 price = tokenInfo.info[topToken].data.price;
            uint256 mc = tokenInfo.info[topToken].data.marketCap;
            uint256 liquidity = tokenInfo.info[topToken].data.liquidity;
            uint256 volume = tokenInfo.info[topToken].data.volume;
            emit TokenEnteredTop4(gameNumber, topToken, maxScore, price, mc, liquidity, volume);
        }
    }

    /// @dev valid only if:
    ///          - game is in progress
    ///          - the final phrase has not started yet
    ///          - knockout phrase has ended
    ///          - exceed knockout phrase duration
    function _validateStartFinalPhrase(GameState storage _gameState) private view {
        if (_gameState.startedAt == 0) {
            revert InvalidGame();
        }

        if (_gameState.knockoutStartAt == 0) {
            revert CannotEnterFinalPhraseYet();
        }

        uint256 knockoutEndTime = _gameState.knockoutStartAt + _gameState.knockoutPhraseDuration;

        if (block.timestamp < knockoutEndTime) {
            revert CannotEnterFinalPhraseYet();
        }

        if (_gameState.finalStartAt != 0) {
            revert FinalPhraseAlreadyStarted();
        }

        uint256 len = _gameState.knockoutPhraseTokens.length;
        if (len < _gameConfig.knockoutTokenNumber) {
            revert InsufficientKnockoutTokens(len);
        }
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                          FINALIZE GAME                     *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function finalizeGame() external onlyOperator {
        GameState storage _gameState = _gameStateForGameNumber[gameNumber];
        _validateFinalizeGame(_gameState);

        (address highestToken, address lowestToken, uint256 highestPrice, uint256 lowestPrice) =
            _calculateWinners(_gameState);

        _gameState.winners = [highestToken, lowestToken];

        for (uint256 i = 0; i < _gameState.finalTokens.length; i++) {
            address token = _gameState.finalTokens[i];
            if (token != highestToken && token != lowestToken) {
                _withdrawTokenLiqudity(_gameState, token);
            }
        }

        (uint256 highestLiquidityReward, uint256 lowestLiquidityReward, uint256 prizePoolFee) =
            _getLiquidityRewards(_gameState);

        protocolFeeBalance += prizePoolFee;

        _gameState.finalizedAt = uint40(block.timestamp);

        emit GameFinalized(
            gameNumber,
            highestToken,
            lowestToken,
            highestPrice,
            lowestPrice,
            highestLiquidityReward,
            lowestLiquidityReward,
            2 * launchFee
        );
    }

    function _calculateWinners(GameState storage _gameState)
        private
        view
        returns (address highestPriceToken, address lowestPriceToken, uint256 highestPrice, uint256 lowestPrice)
    {
        address[] memory finalTokens_ = _gameState.finalTokens;
        uint256 length = finalTokens_.length;
        {
            TokenInfo storage tokenInfo = _tokenInfoForGameNumber[gameNumber];
            highestPriceToken = finalTokens_[0];
            highestPrice = tokenInfo.info[highestPriceToken].data.price;
            lowestPriceToken = finalTokens_[0];
            lowestPrice = tokenInfo.info[lowestPriceToken].data.price;

            /// @notice price is caculated in token/ETH:
            ///             - the lower the `data.price` is, the higher its price in ETH/token
            ///             - and we are comparing price in ETH/token
            for (uint256 i = 1; i < length; i++) {
                address token = finalTokens_[i];
                uint256 tokenPrice = tokenInfo.info[token].data.price;
                // highest at the start of the game has priority
                if (tokenPrice <= highestPrice) {
                    highestPrice = tokenPrice;
                    highestPriceToken = token;
                }
                // lowest at the start of the game has priority
                if (tokenPrice > lowestPrice) {
                    lowestPrice = tokenPrice;
                    lowestPriceToken = token;
                }
            }
        }
    }

    /// @dev valid only if:
    ///          - game has started
    ///          - game has not ended yet
    ///          - final phrase has ended
    function _validateFinalizeGame(GameState storage _gameState) private view {
        if (_gameState.startedAt == 0) {
            revert InvalidGame();
        }

        if (_gameState.finalizedAt != 0) {
            revert GameAlreadyFinalized();
        }

        uint40 finalizeTime = _gameState.finalizedAt + _gameState.finalPhaseDuration;
        if (block.timestamp < finalizeTime) {
            revert CannotFinalizeYet();
        }
    }

    function _withdrawTokenLiqudity(GameState storage _gameState, address token) internal {
        _tokenInfoForGameNumber[gameNumber].info[token].trading = false;
        address _pair = _factory.getPair(token, _router.WGAS());
        uint256 liquidity_ = Pair(payable(_pair)).withdrawAllETH(address(this));
        _gameState.liquidityReserve += liquidity_;
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                         LAUNCH TO DEX                      *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function _withdrawLiquidity(address token) internal returns(uint256 amount){
        _tokenInfoForGameNumber[gameNumber].info[token].trading = false;
        address _pair = _factory.getPair(token, _router.WGAS());
        amount = Pair(payable(_pair)).withdrawAllETH(address(this));
    }

    function launchPoolV3(
        address tk,
        int24 poolTick_,
        int24 tickLower_,
        int24 tickHigher_,
        uint256 minTkAmount,
        uint256 minGasAmount
    )
        external
        payable
        onlyOperator
    {
        GameState storage _gameState = _gameStateForGameNumber[gameNumber];
        address[] memory winners_ = _gameState.winners;
        _validateLaunch(_gameState, winners_, tk);

        uint256 liquidity;
        {
            (uint256 highestLiquidityReward, uint256 lowestLiquidityReward,) = _getLiquidityRewards(_gameState);
            if (tk == winners_[0]) {
                liquidity += highestLiquidityReward;
            } else if (tk == winners_[1]) {
                liquidity += lowestLiquidityReward;
            } else {
                revert NotWinners();
            }
        }

        uint256 tkReserveAmount = ERC20(winners_[0]).totalSupply() - _gameConfig.presaleTotalSupply;

        _dexLauncherV3.setTick(poolTick_, tickLower_, tickHigher_);

        _launchTokenToDexV3(tk, tkReserveAmount, liquidity, minTkAmount, minGasAmount);
    }

    function _launchTokenToDexV3(
        address token,
        uint256 tkAmount,
        uint256 gasAmount,
        uint256 minTkAmount,
        uint256 minGasAmount
    )
        internal
    {
        _router.withdrawTokens(token, tkAmount, address(this));
        // highestLiquidityReward += reserveAmount;

        IERC20(token).approve(address(_dexLauncherV3), tkAmount);

        (uint256 tokenId, address _pool, uint128 liquidity, address tk0, uint256 amount0, address tk1, uint256 amount1)
        = _dexLauncherV3.createAndMintLiquidity{value: gasAmount}(token, tkAmount, minTkAmount, minGasAmount);

        emit V3PoolLaunched(gameNumber, token, _pool, tokenId, tk0, amount0, tk1, amount1, liquidity);
    }

    function launchPoolV2(address tk, uint256 minTkAmount, uint256 minGasAmount) external payable onlyOperator {
        GameState storage _gameState = _gameStateForGameNumber[gameNumber];
        address[] memory winners_ = _gameState.winners;
        _validateLaunch(_gameState, winners_, tk);

        uint256 liquidity;
        {
            (uint256 highestLiquidityReward, uint256 lowestLiquidityReward,) = _getLiquidityRewards(_gameState);
            if (tk == winners_[0]) {
                liquidity += highestLiquidityReward;
            } else if (tk == winners_[1]) {
                liquidity += lowestLiquidityReward;
            } else {
                revert NotWinners();
            }
        }
        liquidity += _withdrawLiquidity(tk);

        uint256 tkReserveAmount = ERC20(winners_[0]).totalSupply() - _gameConfig.presaleTotalSupply;

        _launchTokenToDexV2(tk, tkReserveAmount, liquidity, minTkAmount, minGasAmount);
    }

    function _launchTokenToDexV2(
        address token,
        uint256 tkAmount,
        uint256 gasAmount,
        uint256 minTkAmount,
        uint256 minGasAmount
    )
        internal
    {
        _router.withdrawTokens(token, tkAmount, address(this));
        // highestLiquidityReward += reserveAmount;

        IERC20(token).approve(address(_dexLauncherV2), tkAmount);

        (address _pool, uint256 liquidity, uint256 amount0, uint256 amount1) =
            _dexLauncherV2.createAndMintLiquidity{value: gasAmount}(token, tkAmount, minTkAmount, minGasAmount);

        emit V2PoolLaunched(gameNumber, token, _pool, amount0, amount1, liquidity);
    }

    function _getLiquidityRewards(GameState storage _gameState)
        internal
        view
        returns (uint256 highestLiquidityReward, uint256 lowestLiquidityReward, uint256 prizePoolFee)
    {
        highestLiquidityReward =
            (_gameState.liquidityReserve * _gameConfig.winnerLpBp) / BASIS_POINTS_DIVISOR - launchFee;

        lowestLiquidityReward = _gameState.liquidityReserve - highestLiquidityReward - launchFee;
        prizePoolFee = 2 * launchFee;
    }

    function _validateLaunch(GameState storage _gameState, address[] memory winners_, address tk) private view {
        if (_gameState.startedAt == 0) {
            revert InvalidGame();
        }

        if (_gameState.finalizedAt == 0) {
            revert GameIsNotOver();
        }

        if (tk != winners_[0] && tk != winners_[1]) {
            revert NotWinners();
        }

        if (_dexPools[tk] != address(0)) {
            revert DexPoolAlreadyExisted();
        }
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                         CREATE TOKEN                       *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function createToken(TokenCreation memory tokenCreation)
        public
        payable
        override
        nonReentrant
        returns (address, address, uint256)
    {
        // validate game state
        GameState storage _gameState = _gameStateForGameNumber[gameNumber];
        _validateCreateToken(_gameState);

        // create token
        ERC20 _token = new ERC20(tokenCreation.name, tokenCreation.ticker, tokenMaxTx);
        gameNumberForToken[address(_token)] = gameNumber;

        // create token pair
        address _pair = _factory.createPair(address(_token), _router.WGAS());

        Pair pair_ = Pair(payable(_pair));

        uint256 supply = _token.totalSupply();

        require(_approval(address(_router), address(_token), supply));

        // transfer liquidity
        uint256 createTokenFee = _gameConfig.createTokenFee;
        uint256 liquidity;

        liquidity = msg.value - createTokenFee;
        protocolFeeBalance += createTokenFee;

        _router.addLiquidityETH{value: liquidity}(address(_token), supply);

        // store token and token pair info
        Token memory token_;
        {
            Data memory _data = Data({
                token: address(_token),
                name: tokenCreation.name,
                ticker: tokenCreation.ticker,
                supply: 0,
                price: supply / pair_.MINIMUM_LIQUIDITY1(),
                marketCap: pair_.MINIMUM_LIQUIDITY1(),
                liquidity: liquidity * 2,
                _liquidity: pair_.MINIMUM_LIQUIDITY1() * 2,
                volume: 0,
                volume24H: 0,
                prevPrice: supply / pair_.MINIMUM_LIQUIDITY1(),
                lastUpdated: block.timestamp,
                purchaseNumber: 0
            });

            token_ = Token({
                creator: msg.sender,
                token: address(_token),
                pair: _pair,
                data: _data,
                trading: true,
                tradingOnDex: false
            });
        }

        // update token list
        _tokenInfoForGameNumber[gameNumber].info[address(_token)] = token_;
        _gameStateForGameNumber[gameNumber].tokens.push(address(_token));

        emit TokenCreated(
            gameNumber,
            address(_token),
            msg.sender,
            address(pair_),
            tokenCreation.name,
            tokenCreation.ticker,
            tokenCreation.img,
            tokenCreation.desc,
            tokenCreation.urls[0],
            tokenCreation.urls[1],
            tokenCreation.urls[2]
        );

        // TODO: emit token price after token creation

        return (address(_token), _pair, _gameStateForGameNumber[gameNumber].tokens.length);
    }

    // @dev valid only if:
    //          - game is in process
    //          - sufficient value or createTokenFee
    function _validateCreateToken(GameState storage _gameState) private view {
        if (_gameState.startedAt == 0) {
            revert NoGameRunning();
        }

        uint256 createTokenFee = _gameConfig.createTokenFee;
        if (msg.value < createTokenFee) {
            revert BuyTooLow();
        }

        uint256 presaleGoal = _gameState.knockoutGoalAmount;

        uint256 withoutCreateTokenFee;
        unchecked {
            withoutCreateTokenFee = msg.value - createTokenFee;
        }
        if (withoutCreateTokenFee >= presaleGoal) {
            revert CannotCreateTokenWithAlreadyRaisedFunds();
        }
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                          TOKEN TRADE                       *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function presaleSellTokens(uint256 amountIn, address tk, address to) public override nonReentrant returns (bool) {
        _validateBurnPresale(tk, amountIn);

        address _pair = _factory.getPair(tk, _router.WGAS());

        Pair pair = Pair(payable(_pair));

        Data storage tokenData = _tokenInfoForGameNumber[gameNumber].info[tk].data;

        (
            ,
            // uint256 reserveA,
            uint256 _reserveA,
            uint256 reserveB,
            uint256 _reserveB
        ) = pair.getReserves();

        (uint256 amount0In, uint256 amount1Out) = _router.swapTokensForETH(amountIn, tk, to);

        emit Presale(gameNumber, tk, msg.sender, to, false, amount0In, amount1Out);

        {
            uint256 balance = IERC20(tk).balanceOf(to);
            emit HolderPosition(to, tk, balance);
        }

        // uint256 newReserveA = reserveA + amount0In;
        uint256 _newReserveA = _reserveA + amount0In;
        uint256 newReserveB = reserveB - amount1Out;
        uint256 _newReserveB = _reserveB - amount1Out;

        tokenData.supply -= amount0In;

        uint256 duration = block.timestamp - tokenData.lastUpdated;

        tokenData.prevPrice = duration > 86400 ? tokenData.price : tokenData.prevPrice;
        tokenData.price = _newReserveA / _newReserveB;
        tokenData.marketCap = (tokenData.supply * _newReserveB) / _newReserveA;
        tokenData.liquidity = newReserveB * 2;
        tokenData._liquidity = _newReserveB * 2;
        tokenData.volume = tokenData.volume + amount1Out;
        tokenData.volume24H = duration > 86400 ? amount1Out : tokenData.volume24H + amount1Out;

        if (
            _gameStateForGameNumber[gameNumber].knockoutStartAt != 0
                && _gameStateForGameNumber[gameNumber].finalStartAt == 0
        ) {
            tokenData.purchaseNumber += 1;
        }

        if (duration > 86400) {
            tokenData.lastUpdated = block.timestamp;
        }

        emit TokenInfoUpdated(
            tk, address(pair), tokenData.price, tokenData.marketCap, tokenData.liquidity, tokenData.volume
        );

        return true;
    }

    function _validateBurnPresale(address token, uint256 amount) private view {
        if (amount == 0) {
            revert MustBurnSomething();
        }

        uint48 game = gameNumberForToken[token];
        if (game == 0) {
            revert TokenDoesNotExist();
        }

        if (amount > IERC20(token).balanceOf(msg.sender)) {
            revert InsufficientBalance();
        }
        if (!_tokenInfoForGameNumber[gameNumber].info[address(token)].trading) {
            revert TokenNotTradable();
        }
    }

    function presaleBuyTokens(address tk, address to) public payable override nonReentrant returns (bool) {
        _validateMintPresale(tk, to);

        address _pair = _factory.getPair(tk, _router.WGAS());

        Pair pair = Pair(payable(_pair));

        (
            ,
            // uint256 reserveA,
            uint256 _reserveA,
            uint256 reserveB,
            uint256 _reserveB
        ) = pair.getReserves();

        (uint256 amount1In, uint256 amount0Out) = _router.swapETHForTokens{value: msg.value}(tk, to);

        Data storage tokenData = _tokenInfoForGameNumber[gameNumber].info[tk].data;

        if (tokenData.supply + amount0Out > _gameConfig.presaleTotalSupply) {
            revert ReachSupplyLimit();
        }

        emit Presale(gameNumber, tk, msg.sender, to, true, amount0Out, amount1In);

        {
            uint256 balance = IERC20(tk).balanceOf(to);
            emit HolderPosition(to, tk, balance);
        }

        // uint256 newReserveA = reserveA - amount0Out;
        uint256 _newReserveA = _reserveA - amount0Out;
        uint256 newReserveB = reserveB + amount1In;
        uint256 _newReserveB = _reserveB + amount1In;

        tokenData.supply += amount0Out;

        uint256 duration = block.timestamp - tokenData.lastUpdated;

        uint256 volume = duration > 86400 ? amount1In : tokenData.volume24H + amount1In;
        uint256 _price = duration > 86400 ? tokenData.price : tokenData.prevPrice;

        tokenData.price = _newReserveA / _newReserveB;
        tokenData.marketCap = (tokenData.supply * _newReserveB) / _newReserveA;
        tokenData.liquidity = newReserveB * 2;
        tokenData._liquidity = _newReserveB * 2;
        tokenData.volume = tokenData.volume + amount1In;
        tokenData.volume24H = volume;
        tokenData.prevPrice = _price;

        if (
            _gameStateForGameNumber[gameNumber].knockoutStartAt != 0
                && _gameStateForGameNumber[gameNumber].finalStartAt == 0
        ) {
            tokenData.purchaseNumber += 1;
        }

        if (duration > 86400) {
            tokenData.lastUpdated = block.timestamp;
        }

        emit TokenInfoUpdated(
            tk, address(pair), tokenData.price, tokenData.marketCap, tokenData.liquidity, tokenData.volume
        );

        _validateAndEnterKnockoutPhrase(tk, tokenData.marketCap);

        return true;
    }

    function _validateMintPresale(address token, address to) private {
        if (msg.value == 0) {
            revert BuyTooLow();
        }

        if (to == address(0)) {
            revert CannotBuyToZeroAddress();
        }

        uint48 game = gameNumberForToken[token];
        if (game == 0) {
            revert TokenDoesNotExist();
        }

        if (!_tokenInfoForGameNumber[gameNumber].info[address(token)].trading) {
            revert TokenNotTradable();
        }
    }

    function _approval(address _user, address _token, uint256 amount) private returns (bool) {
        require(_user != address(0), "Zero addresses are not allowed.");
        require(_token != address(0), "Zero addresses are not allowed.");

        IERC20 token_ = IERC20(_token);

        token_.approve(_user, amount);

        return true;
    }

    function _validateAndEnterKnockoutPhrase(address tk, uint256 mCap) internal {
        // Fetch game state and knockout config
        GameState storage _gameState = _gameStateForGameNumber[gameNumber];
        GameConfig storage gameConfig_ = _gameConfig;

        // Check if the token is already a knockout token
        if (_gameState.isKnockoutToken[tk]) {
            return;
        }

        // Get knockout phrase tokens and validate the knockout number
        address[] storage knockoutPhraseTokens = _gameState.knockoutPhraseTokens;
        uint256 knockoutNumber = gameConfig_.knockoutTokenNumber;

        // If the knockout phrase tokens array is already full, return early
        if (knockoutPhraseTokens.length >= knockoutNumber) {
            return;
        }

        if (mCap < gameConfig_.knockoutGoalAmount) {
            return;
        }

        // Elect `tk` to knockout phrase and mark it as a knockout token
        knockoutPhraseTokens.push(tk);
        _gameState.isKnockoutToken[tk] = true;

        // Calculate remaining seats and update the phase end block if necessary
        uint256 remainingSeats = knockoutNumber - knockoutPhraseTokens.length;
        if (remainingSeats == 0) {
            _gameState.phrase1EndBlock = block.number;
            emit Phrase1Ended(gameNumber, block.number);
        }

        // Emit event for token entering knockout phase
        emit TokenEnteredKnockout(gameNumber, tk, remainingSeats);
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                         GAME CONFIG                        *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function setGameConfig(GameConfig calldata newConfig) external override onlyOperator {
        _setGameConfig(newConfig);
    }

    function _setGameConfig(GameConfig memory newConfig) internal {
        if (newConfig.finalPhaseDuration < minFinalPhaseDuration) {
            revert FinalPhaseDurationTooShort();
        }
        if (newConfig.finalPhaseDuration > maxFinalPhaseDuration) {
            revert FinalPhaseDurationTooLong();
        }

        if (newConfig.knockoutGoalAmount < minKnockoutAmount) {
            revert KnockoutGoalAmountTooLow();
        }
        if (newConfig.knockoutGoalAmount > maxKnockoutAmount) {
            revert KnockoutGoalAmountTooHigh();
        }

        if (newConfig.knockoutTokenNumber < minKnockoutTokenNumber) {
            revert KnockoutTokenNumberTooLow();
        }
        if (newConfig.knockoutTokenNumber > maxKnockoutTokenNumber) {
            revert KnockoutTokenNumberTooHigh();
        }

        if (newConfig.createTokenFee > maxCreateTokenFee) {
            revert CreateTokenFeeTooHigh();
        }

        if (newConfig.blockGapNumber < minBlockGapNumber) {
            revert BlockGapNumberTooLow();
        }
        if (newConfig.blockGapNumber > maxBlockGapNumber) {
            revert BlockGapNumberTooHigh();
        }

        if (newConfig.winnerLpBp < minWinnerLpBp) {
            revert WinnerLpBpTooLow();
        }
        if (newConfig.winnerLpBp > maxWinnerLpBp) {
            revert WinnerLpBpTooHigh();
        }

        _gameConfig = newConfig;
        emit GameConfigUpdated(newConfig);
    }

    function gameConfig() external view override returns (GameConfig memory) {
        return _gameConfig;
    }

    //Auth

    error InvalidAccess();

    event OperatorUpdated(address indexed operator, bool isAllowed);

    modifier onlyOperator() {
        if (!_isOperator[msg.sender]) {
            revert InvalidAccess();
        }
        _;
    }

    function setOperator(address _operator, bool _isAllowed) external onlyOwner {
        _isOperator[_operator] = _isAllowed;
        emit OperatorUpdated(_operator, _isAllowed);
    }
}
