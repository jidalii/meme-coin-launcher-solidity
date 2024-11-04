import {
  createUseReadContract,
  createUseWriteContract,
  createUseSimulateContract,
  createUseWatchContractEvent,
} from 'wagmi/codegen'

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MemexGame
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

export const memexGameAbi = [
  {
    type: 'constructor',
    inputs: [
      { name: 'factory_', internalType: 'address', type: 'address' },
      { name: 'router_', internalType: 'address', type: 'address' },
      { name: 'dexLuancher_', internalType: 'address', type: 'address' },
    ],
    stateMutability: 'nonpayable',
  },
  { type: 'error', inputs: [], name: 'BlockGapNumberTooHigh' },
  { type: 'error', inputs: [], name: 'BlockGapNumberTooLow' },
  { type: 'error', inputs: [], name: 'BuyTooLow' },
  { type: 'error', inputs: [], name: 'CannotBuyInactiveGame' },
  { type: 'error', inputs: [], name: 'CannotBuyToZeroAddress' },
  {
    type: 'error',
    inputs: [],
    name: 'CannotCreateTokenWithAlreadyRaisedFunds',
  },
  { type: 'error', inputs: [], name: 'CannotEnterFinalPhraseYet' },
  { type: 'error', inputs: [], name: 'CannotFinalizeYet' },
  { type: 'error', inputs: [], name: 'CreateTokenFeeTooHigh' },
  { type: 'error', inputs: [], name: 'DexPoolAlreadyExisted' },
  { type: 'error', inputs: [], name: 'FinalPhaseDurationTooLong' },
  { type: 'error', inputs: [], name: 'FinalPhaseDurationTooShort' },
  { type: 'error', inputs: [], name: 'FinalPhraseAlreadyStarted' },
  { type: 'error', inputs: [], name: 'GameAlreadyFinalized' },
  { type: 'error', inputs: [], name: 'GameIsNotOver' },
  { type: 'error', inputs: [], name: 'GameNotFinalized' },
  { type: 'error', inputs: [], name: 'InsufficientAmount' },
  { type: 'error', inputs: [], name: 'InsufficientBalance' },
  { type: 'error', inputs: [], name: 'InsufficientBlockGap' },
  {
    type: 'error',
    inputs: [{ name: 'number', internalType: 'uint256', type: 'uint256' }],
    name: 'InsufficientKnockoutTokens',
  },
  { type: 'error', inputs: [], name: 'InvalidAccess' },
  { type: 'error', inputs: [], name: 'InvalidGame' },
  { type: 'error', inputs: [], name: 'InvalidGameNumber' },
  { type: 'error', inputs: [], name: 'KnockoutGoalAmountTooHigh' },
  { type: 'error', inputs: [], name: 'KnockoutGoalAmountTooLow' },
  { type: 'error', inputs: [], name: 'KnockoutTokenNumberTooHigh' },
  { type: 'error', inputs: [], name: 'KnockoutTokenNumberTooLow' },
  { type: 'error', inputs: [], name: 'LpFeeBpTooHigh' },
  { type: 'error', inputs: [], name: 'LpFeeBpTooLow' },
  { type: 'error', inputs: [], name: 'MustBurnSomething' },
  { type: 'error', inputs: [], name: 'NoGameRunning' },
  { type: 'error', inputs: [], name: 'NotWinners' },
  { type: 'error', inputs: [], name: 'ReachSupplyLimit' },
  { type: 'error', inputs: [], name: 'ReentrancyGuardReentrantCall' },
  { type: 'error', inputs: [], name: 'TokenAlreadyInGame' },
  { type: 'error', inputs: [], name: 'TokenCreationEnded' },
  { type: 'error', inputs: [], name: 'TokenDoesNotExist' },
  { type: 'error', inputs: [], name: 'TokenNotTradable' },
  { type: 'error', inputs: [], name: 'TokenPoolNotFound' },
  { type: 'error', inputs: [], name: 'WinnerLpBpTooHigh' },
  { type: 'error', inputs: [], name: 'WinnerLpBpTooLow' },
  { type: 'error', inputs: [], name: 'ZeroAddress' },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'amount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      { name: 'to', internalType: 'address', type: 'address', indexed: false },
    ],
    name: 'FeeWithdrawal',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'gameNumnber',
        internalType: 'uint48',
        type: 'uint48',
        indexed: true,
      },
      {
        name: 'finalTokens',
        internalType: 'address[]',
        type: 'address[]',
        indexed: false,
      },
    ],
    name: 'FinalPhraseStarted',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'config',
        internalType: 'struct IMemexGame.GameConfig',
        type: 'tuple',
        components: [
          {
            name: 'finalPhaseDuration',
            internalType: 'uint40',
            type: 'uint40',
          },
          {
            name: 'knockoutPhraseDuration',
            internalType: 'uint40',
            type: 'uint40',
          },
          {
            name: 'knockoutTokenNumber',
            internalType: 'uint256',
            type: 'uint256',
          },
          {
            name: 'knockoutGoalAmount',
            internalType: 'uint256',
            type: 'uint256',
          },
          {
            name: 'presaleTotalSupply',
            internalType: 'uint256',
            type: 'uint256',
          },
          { name: 'createTokenFee', internalType: 'uint256', type: 'uint256' },
          { name: 'blockGapNumber', internalType: 'uint40', type: 'uint40' },
          { name: 'winnerLpBp', internalType: 'uint256', type: 'uint256' },
        ],
        indexed: false,
      },
    ],
    name: 'GameConfigUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'gameNumber',
        internalType: 'uint48',
        type: 'uint48',
        indexed: true,
      },
      {
        name: 'highestPriceToken',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'lowestPriceToken',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'highestTokenPrice',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'lowestTokenPrice',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'highestLiquidityReward',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'lowestLiquidityReward',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'prizePoolFee',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'GameFinalized',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'gameNumber',
        internalType: 'uint48',
        type: 'uint48',
        indexed: true,
      },
    ],
    name: 'GameStarted',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'owner',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'value',
        internalType: 'uint256',
        type: 'uint256',
        indexed: true,
      },
    ],
    name: 'HolderPosition',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'gameNumber',
        internalType: 'uint48',
        type: 'uint48',
        indexed: true,
      },
      {
        name: 'token1',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'token2',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'token3',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'token4',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
    ],
    name: 'KnockoutPairing',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'luanchFee',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'LaunchFeeUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'factory',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'router',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'dexLauncher',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
    ],
    name: 'MemexDayInitialized',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'operator',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'isAllowed', internalType: 'bool', type: 'bool', indexed: false },
    ],
    name: 'OperatorUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'previousOwner',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'newOwner',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
    ],
    name: 'OwnershipTransferred',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'gameNumber',
        internalType: 'uint48',
        type: 'uint48',
        indexed: true,
      },
      {
        name: 'blockNumber',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Phrase1Ended',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'gameNumber',
        internalType: 'uint48',
        type: 'uint48',
        indexed: true,
      },
      {
        name: 'token',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'from', internalType: 'address', type: 'address', indexed: true },
      { name: 'to', internalType: 'address', type: 'address', indexed: false },
      { name: 'isMint', internalType: 'bool', type: 'bool', indexed: false },
      {
        name: 'tokenAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'ethAmount',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'Presale',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'gameNumber',
        internalType: 'uint48',
        type: 'uint48',
        indexed: true,
      },
      {
        name: 'token',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'creator',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'pair',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      { name: 'name', internalType: 'string', type: 'string', indexed: false },
      {
        name: 'ticker',
        internalType: 'string',
        type: 'string',
        indexed: false,
      },
      { name: 'image', internalType: 'string', type: 'string', indexed: false },
      {
        name: 'description',
        internalType: 'string',
        type: 'string',
        indexed: false,
      },
      {
        name: 'twitter',
        internalType: 'string',
        type: 'string',
        indexed: false,
      },
      {
        name: 'telegram',
        internalType: 'string',
        type: 'string',
        indexed: false,
      },
      {
        name: 'website',
        internalType: 'string',
        type: 'string',
        indexed: false,
      },
    ],
    name: 'TokenCreated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'gameNumber',
        internalType: 'uint48',
        type: 'uint48',
        indexed: true,
      },
      {
        name: 'token',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      {
        name: 'remainingSeats',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'TokenEnteredKnockout',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'gameNumber',
        internalType: 'uint48',
        type: 'uint48',
        indexed: true,
      },
      {
        name: 'winner',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'price',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'marketCap',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'liquidity',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'volume',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'TokenEnteredTop4',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'token',
        internalType: 'address',
        type: 'address',
        indexed: true,
      },
      { name: 'pair', internalType: 'address', type: 'address', indexed: true },
      {
        name: 'price',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'marketCap',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'liquidity',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'volume',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'TokenInfoUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'tokenMaxTx',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'TokenMaxTxUpdated',
  },
  {
    type: 'event',
    anonymous: false,
    inputs: [
      {
        name: 'gameNumber',
        internalType: 'uint256',
        type: 'uint256',
        indexed: true,
      },
      { name: 'tk', internalType: 'address', type: 'address', indexed: false },
      {
        name: 'poolAddress',
        internalType: 'address',
        type: 'address',
        indexed: false,
      },
      {
        name: 'amount0',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'amount1',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
      {
        name: 'liquidity',
        internalType: 'uint256',
        type: 'uint256',
        indexed: false,
      },
    ],
    name: 'V2PoolLaunched',
  },
  {
    type: 'function',
    inputs: [],
    name: 'BASIS_POINTS_DIVISOR',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'UNI_V3_POS',
    outputs: [{ name: '', internalType: 'address', type: 'address' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'WGAS',
    outputs: [{ name: '', internalType: 'address', type: 'address' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [{ name: '_gameNumber', internalType: 'uint48', type: 'uint48' }],
    name: 'allTokens',
    outputs: [{ name: '', internalType: 'address[]', type: 'address[]' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [
      {
        name: 'tokenCreation',
        internalType: 'struct IMemexGame.TokenCreation',
        type: 'tuple',
        components: [
          { name: 'name', internalType: 'string', type: 'string' },
          { name: 'ticker', internalType: 'string', type: 'string' },
          { name: 'desc', internalType: 'string', type: 'string' },
          { name: 'img', internalType: 'string', type: 'string' },
          { name: 'urls', internalType: 'string[3]', type: 'string[3]' },
        ],
      },
    ],
    name: 'createToken',
    outputs: [
      { name: '', internalType: 'address', type: 'address' },
      { name: '', internalType: 'address', type: 'address' },
      { name: '', internalType: 'uint256', type: 'uint256' },
    ],
    stateMutability: 'payable',
  },
  {
    type: 'function',
    inputs: [],
    name: 'enterFinalPhrase',
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    inputs: [{ name: '_gameNumber', internalType: 'uint48', type: 'uint48' }],
    name: 'finalTokens',
    outputs: [{ name: '', internalType: 'address[]', type: 'address[]' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'finalizeGame',
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    inputs: [],
    name: 'gameConfig',
    outputs: [
      {
        name: '',
        internalType: 'struct IMemexGame.GameConfig',
        type: 'tuple',
        components: [
          {
            name: 'finalPhaseDuration',
            internalType: 'uint40',
            type: 'uint40',
          },
          {
            name: 'knockoutPhraseDuration',
            internalType: 'uint40',
            type: 'uint40',
          },
          {
            name: 'knockoutTokenNumber',
            internalType: 'uint256',
            type: 'uint256',
          },
          {
            name: 'knockoutGoalAmount',
            internalType: 'uint256',
            type: 'uint256',
          },
          {
            name: 'presaleTotalSupply',
            internalType: 'uint256',
            type: 'uint256',
          },
          { name: 'createTokenFee', internalType: 'uint256', type: 'uint256' },
          { name: 'blockGapNumber', internalType: 'uint40', type: 'uint40' },
          { name: 'winnerLpBp', internalType: 'uint256', type: 'uint256' },
        ],
      },
    ],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'gameNumber',
    outputs: [{ name: '', internalType: 'uint48', type: 'uint48' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [{ name: '', internalType: 'address', type: 'address' }],
    name: 'gameNumberForToken',
    outputs: [{ name: '', internalType: 'uint48', type: 'uint48' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [{ name: '_gameNumber', internalType: 'uint48', type: 'uint48' }],
    name: 'knockoutTokens',
    outputs: [{ name: '', internalType: 'address[]', type: 'address[]' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'launchFee',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [
      { name: 'tk', internalType: 'address', type: 'address' },
      { name: 'minTkAmount', internalType: 'uint256', type: 'uint256' },
      { name: 'minGasAmount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'launchPoolV2',
    outputs: [],
    stateMutability: 'payable',
  },
  {
    type: 'function',
    inputs: [
      { name: 'tk', internalType: 'address', type: 'address' },
      { name: 'poolTick_', internalType: 'int24', type: 'int24' },
      { name: 'tickLower_', internalType: 'int24', type: 'int24' },
      { name: 'tickHigher_', internalType: 'int24', type: 'int24' },
      { name: 'minTkAmount', internalType: 'uint256', type: 'uint256' },
      { name: 'minGasAmount', internalType: 'uint256', type: 'uint256' },
    ],
    name: 'launchPoolV3',
    outputs: [],
    stateMutability: 'payable',
  },
  {
    type: 'function',
    inputs: [{ name: '_gameNumber', internalType: 'uint40', type: 'uint40' }],
    name: 'liquidityReserves',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'maxBlockGapNumber',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'maxCreateTokenFee',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'maxFinalPhaseDuration',
    outputs: [{ name: '', internalType: 'uint40', type: 'uint40' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'maxKnockoutAmount',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'maxKnockoutDuration',
    outputs: [{ name: '', internalType: 'uint40', type: 'uint40' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'maxKnockoutTokenNumber',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'maxLpFeeBp',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'maxPostGameBuyDuration',
    outputs: [{ name: '', internalType: 'uint40', type: 'uint40' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'maxWinnerLpBp',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'minBlockGapNumber',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'minFinalPhaseDuration',
    outputs: [{ name: '', internalType: 'uint40', type: 'uint40' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'minKnockoutAmount',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'minKnockoutDuration',
    outputs: [{ name: '', internalType: 'uint40', type: 'uint40' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'minKnockoutTokenNumber',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'minLpFeeBp',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'minPostGameBuyDuration',
    outputs: [{ name: '', internalType: 'uint40', type: 'uint40' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'minWinnerLpBp',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'owner',
    outputs: [{ name: '', internalType: 'address', type: 'address' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [{ name: 'token', internalType: 'address', type: 'address' }],
    name: 'pool',
    outputs: [{ name: '', internalType: 'address', type: 'address' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [
      { name: 'tk', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'address', type: 'address' },
    ],
    name: 'presaleBuyTokens',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
    stateMutability: 'payable',
  },
  {
    type: 'function',
    inputs: [
      { name: 'amountIn', internalType: 'uint256', type: 'uint256' },
      { name: 'tk', internalType: 'address', type: 'address' },
      { name: 'to', internalType: 'address', type: 'address' },
    ],
    name: 'presaleSellTokens',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    inputs: [],
    name: 'protocolFeeBalance',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [],
    name: 'randomizeKnockoutPairing',
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    inputs: [],
    name: 'renounceOwnership',
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    inputs: [
      {
        name: 'newConfig',
        internalType: 'struct IMemexGame.GameConfig',
        type: 'tuple',
        components: [
          {
            name: 'finalPhaseDuration',
            internalType: 'uint40',
            type: 'uint40',
          },
          {
            name: 'knockoutPhraseDuration',
            internalType: 'uint40',
            type: 'uint40',
          },
          {
            name: 'knockoutTokenNumber',
            internalType: 'uint256',
            type: 'uint256',
          },
          {
            name: 'knockoutGoalAmount',
            internalType: 'uint256',
            type: 'uint256',
          },
          {
            name: 'presaleTotalSupply',
            internalType: 'uint256',
            type: 'uint256',
          },
          { name: 'createTokenFee', internalType: 'uint256', type: 'uint256' },
          { name: 'blockGapNumber', internalType: 'uint40', type: 'uint40' },
          { name: 'winnerLpBp', internalType: 'uint256', type: 'uint256' },
        ],
      },
    ],
    name: 'setGameConfig',
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    inputs: [{ name: '_launchFee', internalType: 'uint56', type: 'uint56' }],
    name: 'setLaunchFee',
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    inputs: [
      { name: '_operator', internalType: 'address', type: 'address' },
      { name: '_isAllowed', internalType: 'bool', type: 'bool' },
    ],
    name: 'setOperator',
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    inputs: [{ name: '_tokenMaxTx', internalType: 'uint56', type: 'uint56' }],
    name: 'setTokenMaxTx',
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    inputs: [],
    name: 'startGame',
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    inputs: [],
    name: 'tokenMaxTx',
    outputs: [{ name: '', internalType: 'uint256', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [
      { name: 'dexLuancher_', internalType: 'address', type: 'address' },
    ],
    name: 'updateDexLauncherV2',
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    inputs: [
      { name: 'dexLuancher_', internalType: 'address', type: 'address' },
    ],
    name: 'updateDexLauncherV3',
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    inputs: [{ name: 'factory_', internalType: 'address', type: 'address' }],
    name: 'updateFactory',
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    inputs: [{ name: 'router_', internalType: 'address', type: 'address' }],
    name: 'updateRouter',
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    inputs: [{ name: '_gameNumber', internalType: 'uint48', type: 'uint48' }],
    name: 'winners',
    outputs: [{ name: '', internalType: 'address[]', type: 'address[]' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    inputs: [
      { name: 'amount', internalType: 'uint256', type: 'uint256' },
      { name: 'to', internalType: 'address', type: 'address' },
    ],
    name: 'withdrawFees',
    outputs: [{ name: '', internalType: 'bool', type: 'bool' }],
    stateMutability: 'nonpayable',
  },
  { type: 'receive', stateMutability: 'payable' },
] as const

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// React
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__
 */
export const useReadMemexGame = /*#__PURE__*/ createUseReadContract({
  abi: memexGameAbi,
})

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"BASIS_POINTS_DIVISOR"`
 */
export const useReadMemexGameBasisPointsDivisor =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'BASIS_POINTS_DIVISOR',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"UNI_V3_POS"`
 */
export const useReadMemexGameUniV3Pos = /*#__PURE__*/ createUseReadContract({
  abi: memexGameAbi,
  functionName: 'UNI_V3_POS',
})

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"WGAS"`
 */
export const useReadMemexGameWgas = /*#__PURE__*/ createUseReadContract({
  abi: memexGameAbi,
  functionName: 'WGAS',
})

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"allTokens"`
 */
export const useReadMemexGameAllTokens = /*#__PURE__*/ createUseReadContract({
  abi: memexGameAbi,
  functionName: 'allTokens',
})

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"finalTokens"`
 */
export const useReadMemexGameFinalTokens = /*#__PURE__*/ createUseReadContract({
  abi: memexGameAbi,
  functionName: 'finalTokens',
})

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"gameConfig"`
 */
export const useReadMemexGameGameConfig = /*#__PURE__*/ createUseReadContract({
  abi: memexGameAbi,
  functionName: 'gameConfig',
})

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"gameNumber"`
 */
export const useReadMemexGameGameNumber = /*#__PURE__*/ createUseReadContract({
  abi: memexGameAbi,
  functionName: 'gameNumber',
})

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"gameNumberForToken"`
 */
export const useReadMemexGameGameNumberForToken =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'gameNumberForToken',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"knockoutTokens"`
 */
export const useReadMemexGameKnockoutTokens =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'knockoutTokens',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"launchFee"`
 */
export const useReadMemexGameLaunchFee = /*#__PURE__*/ createUseReadContract({
  abi: memexGameAbi,
  functionName: 'launchFee',
})

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"liquidityReserves"`
 */
export const useReadMemexGameLiquidityReserves =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'liquidityReserves',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"maxBlockGapNumber"`
 */
export const useReadMemexGameMaxBlockGapNumber =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'maxBlockGapNumber',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"maxCreateTokenFee"`
 */
export const useReadMemexGameMaxCreateTokenFee =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'maxCreateTokenFee',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"maxFinalPhaseDuration"`
 */
export const useReadMemexGameMaxFinalPhaseDuration =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'maxFinalPhaseDuration',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"maxKnockoutAmount"`
 */
export const useReadMemexGameMaxKnockoutAmount =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'maxKnockoutAmount',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"maxKnockoutDuration"`
 */
export const useReadMemexGameMaxKnockoutDuration =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'maxKnockoutDuration',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"maxKnockoutTokenNumber"`
 */
export const useReadMemexGameMaxKnockoutTokenNumber =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'maxKnockoutTokenNumber',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"maxLpFeeBp"`
 */
export const useReadMemexGameMaxLpFeeBp = /*#__PURE__*/ createUseReadContract({
  abi: memexGameAbi,
  functionName: 'maxLpFeeBp',
})

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"maxPostGameBuyDuration"`
 */
export const useReadMemexGameMaxPostGameBuyDuration =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'maxPostGameBuyDuration',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"maxWinnerLpBp"`
 */
export const useReadMemexGameMaxWinnerLpBp =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'maxWinnerLpBp',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"minBlockGapNumber"`
 */
export const useReadMemexGameMinBlockGapNumber =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'minBlockGapNumber',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"minFinalPhaseDuration"`
 */
export const useReadMemexGameMinFinalPhaseDuration =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'minFinalPhaseDuration',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"minKnockoutAmount"`
 */
export const useReadMemexGameMinKnockoutAmount =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'minKnockoutAmount',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"minKnockoutDuration"`
 */
export const useReadMemexGameMinKnockoutDuration =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'minKnockoutDuration',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"minKnockoutTokenNumber"`
 */
export const useReadMemexGameMinKnockoutTokenNumber =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'minKnockoutTokenNumber',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"minLpFeeBp"`
 */
export const useReadMemexGameMinLpFeeBp = /*#__PURE__*/ createUseReadContract({
  abi: memexGameAbi,
  functionName: 'minLpFeeBp',
})

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"minPostGameBuyDuration"`
 */
export const useReadMemexGameMinPostGameBuyDuration =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'minPostGameBuyDuration',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"minWinnerLpBp"`
 */
export const useReadMemexGameMinWinnerLpBp =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'minWinnerLpBp',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"owner"`
 */
export const useReadMemexGameOwner = /*#__PURE__*/ createUseReadContract({
  abi: memexGameAbi,
  functionName: 'owner',
})

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"pool"`
 */
export const useReadMemexGamePool = /*#__PURE__*/ createUseReadContract({
  abi: memexGameAbi,
  functionName: 'pool',
})

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"protocolFeeBalance"`
 */
export const useReadMemexGameProtocolFeeBalance =
  /*#__PURE__*/ createUseReadContract({
    abi: memexGameAbi,
    functionName: 'protocolFeeBalance',
  })

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"tokenMaxTx"`
 */
export const useReadMemexGameTokenMaxTx = /*#__PURE__*/ createUseReadContract({
  abi: memexGameAbi,
  functionName: 'tokenMaxTx',
})

/**
 * Wraps __{@link useReadContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"winners"`
 */
export const useReadMemexGameWinners = /*#__PURE__*/ createUseReadContract({
  abi: memexGameAbi,
  functionName: 'winners',
})

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__
 */
export const useWriteMemexGame = /*#__PURE__*/ createUseWriteContract({
  abi: memexGameAbi,
})

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"createToken"`
 */
export const useWriteMemexGameCreateToken =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'createToken',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"enterFinalPhrase"`
 */
export const useWriteMemexGameEnterFinalPhrase =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'enterFinalPhrase',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"finalizeGame"`
 */
export const useWriteMemexGameFinalizeGame =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'finalizeGame',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"launchPoolV2"`
 */
export const useWriteMemexGameLaunchPoolV2 =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'launchPoolV2',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"launchPoolV3"`
 */
export const useWriteMemexGameLaunchPoolV3 =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'launchPoolV3',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"presaleBuyTokens"`
 */
export const useWriteMemexGamePresaleBuyTokens =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'presaleBuyTokens',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"presaleSellTokens"`
 */
export const useWriteMemexGamePresaleSellTokens =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'presaleSellTokens',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"randomizeKnockoutPairing"`
 */
export const useWriteMemexGameRandomizeKnockoutPairing =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'randomizeKnockoutPairing',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"renounceOwnership"`
 */
export const useWriteMemexGameRenounceOwnership =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'renounceOwnership',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"setGameConfig"`
 */
export const useWriteMemexGameSetGameConfig =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'setGameConfig',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"setLaunchFee"`
 */
export const useWriteMemexGameSetLaunchFee =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'setLaunchFee',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"setOperator"`
 */
export const useWriteMemexGameSetOperator =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'setOperator',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"setTokenMaxTx"`
 */
export const useWriteMemexGameSetTokenMaxTx =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'setTokenMaxTx',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"startGame"`
 */
export const useWriteMemexGameStartGame = /*#__PURE__*/ createUseWriteContract({
  abi: memexGameAbi,
  functionName: 'startGame',
})

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"updateDexLauncherV2"`
 */
export const useWriteMemexGameUpdateDexLauncherV2 =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'updateDexLauncherV2',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"updateDexLauncherV3"`
 */
export const useWriteMemexGameUpdateDexLauncherV3 =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'updateDexLauncherV3',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"updateFactory"`
 */
export const useWriteMemexGameUpdateFactory =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'updateFactory',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"updateRouter"`
 */
export const useWriteMemexGameUpdateRouter =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'updateRouter',
  })

/**
 * Wraps __{@link useWriteContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"withdrawFees"`
 */
export const useWriteMemexGameWithdrawFees =
  /*#__PURE__*/ createUseWriteContract({
    abi: memexGameAbi,
    functionName: 'withdrawFees',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__
 */
export const useSimulateMemexGame = /*#__PURE__*/ createUseSimulateContract({
  abi: memexGameAbi,
})

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"createToken"`
 */
export const useSimulateMemexGameCreateToken =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'createToken',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"enterFinalPhrase"`
 */
export const useSimulateMemexGameEnterFinalPhrase =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'enterFinalPhrase',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"finalizeGame"`
 */
export const useSimulateMemexGameFinalizeGame =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'finalizeGame',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"launchPoolV2"`
 */
export const useSimulateMemexGameLaunchPoolV2 =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'launchPoolV2',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"launchPoolV3"`
 */
export const useSimulateMemexGameLaunchPoolV3 =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'launchPoolV3',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"presaleBuyTokens"`
 */
export const useSimulateMemexGamePresaleBuyTokens =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'presaleBuyTokens',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"presaleSellTokens"`
 */
export const useSimulateMemexGamePresaleSellTokens =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'presaleSellTokens',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"randomizeKnockoutPairing"`
 */
export const useSimulateMemexGameRandomizeKnockoutPairing =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'randomizeKnockoutPairing',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"renounceOwnership"`
 */
export const useSimulateMemexGameRenounceOwnership =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'renounceOwnership',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"setGameConfig"`
 */
export const useSimulateMemexGameSetGameConfig =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'setGameConfig',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"setLaunchFee"`
 */
export const useSimulateMemexGameSetLaunchFee =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'setLaunchFee',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"setOperator"`
 */
export const useSimulateMemexGameSetOperator =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'setOperator',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"setTokenMaxTx"`
 */
export const useSimulateMemexGameSetTokenMaxTx =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'setTokenMaxTx',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"startGame"`
 */
export const useSimulateMemexGameStartGame =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'startGame',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"updateDexLauncherV2"`
 */
export const useSimulateMemexGameUpdateDexLauncherV2 =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'updateDexLauncherV2',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"updateDexLauncherV3"`
 */
export const useSimulateMemexGameUpdateDexLauncherV3 =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'updateDexLauncherV3',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"updateFactory"`
 */
export const useSimulateMemexGameUpdateFactory =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'updateFactory',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"updateRouter"`
 */
export const useSimulateMemexGameUpdateRouter =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'updateRouter',
  })

/**
 * Wraps __{@link useSimulateContract}__ with `abi` set to __{@link memexGameAbi}__ and `functionName` set to `"withdrawFees"`
 */
export const useSimulateMemexGameWithdrawFees =
  /*#__PURE__*/ createUseSimulateContract({
    abi: memexGameAbi,
    functionName: 'withdrawFees',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__
 */
export const useWatchMemexGameEvent = /*#__PURE__*/ createUseWatchContractEvent(
  { abi: memexGameAbi },
)

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"FeeWithdrawal"`
 */
export const useWatchMemexGameFeeWithdrawalEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'FeeWithdrawal',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"FinalPhraseStarted"`
 */
export const useWatchMemexGameFinalPhraseStartedEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'FinalPhraseStarted',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"GameConfigUpdated"`
 */
export const useWatchMemexGameGameConfigUpdatedEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'GameConfigUpdated',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"GameFinalized"`
 */
export const useWatchMemexGameGameFinalizedEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'GameFinalized',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"GameStarted"`
 */
export const useWatchMemexGameGameStartedEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'GameStarted',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"HolderPosition"`
 */
export const useWatchMemexGameHolderPositionEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'HolderPosition',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"KnockoutPairing"`
 */
export const useWatchMemexGameKnockoutPairingEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'KnockoutPairing',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"LaunchFeeUpdated"`
 */
export const useWatchMemexGameLaunchFeeUpdatedEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'LaunchFeeUpdated',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"MemexDayInitialized"`
 */
export const useWatchMemexGameMemexDayInitializedEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'MemexDayInitialized',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"OperatorUpdated"`
 */
export const useWatchMemexGameOperatorUpdatedEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'OperatorUpdated',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"OwnershipTransferred"`
 */
export const useWatchMemexGameOwnershipTransferredEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'OwnershipTransferred',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"Phrase1Ended"`
 */
export const useWatchMemexGamePhrase1EndedEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'Phrase1Ended',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"Presale"`
 */
export const useWatchMemexGamePresaleEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'Presale',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"TokenCreated"`
 */
export const useWatchMemexGameTokenCreatedEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'TokenCreated',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"TokenEnteredKnockout"`
 */
export const useWatchMemexGameTokenEnteredKnockoutEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'TokenEnteredKnockout',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"TokenEnteredTop4"`
 */
export const useWatchMemexGameTokenEnteredTop4Event =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'TokenEnteredTop4',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"TokenInfoUpdated"`
 */
export const useWatchMemexGameTokenInfoUpdatedEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'TokenInfoUpdated',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"TokenMaxTxUpdated"`
 */
export const useWatchMemexGameTokenMaxTxUpdatedEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'TokenMaxTxUpdated',
  })

/**
 * Wraps __{@link useWatchContractEvent}__ with `abi` set to __{@link memexGameAbi}__ and `eventName` set to `"V2PoolLaunched"`
 */
export const useWatchMemexGameV2PoolLaunchedEvent =
  /*#__PURE__*/ createUseWatchContractEvent({
    abi: memexGameAbi,
    eventName: 'V2PoolLaunched',
  })
