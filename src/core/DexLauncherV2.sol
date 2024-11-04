// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "../lib/TransferHelper.sol";
import "../token/interfaces/IWETH.sol";

import "./interfaces/IDexLauncherV2.sol";

contract DexLauncherV2 is IDexLauncherV2, Ownable, ReentrancyGuard {
    address public immutable WGAS;

    IUniswapV2Factory public uniswapV2Factory;
    IUniswapV2Router02 public uniswapV2Router02;

    mapping(uint256 => Deposit) public deposits;
    mapping(address => bool) private _isOperator;

    error InvalidAccess();

    event OperatorUpdated(address indexed operator, bool isAllowed);

    modifier onlyOperator() {
        if (!_isOperator[msg.sender]) {
            revert InvalidAccess();
        }
        _;
    }

    constructor(address uniswapV2Factory_, address uniswapV2Router02_, address wgas_) Ownable(msg.sender) {
        if (uniswapV2Factory_ == address(0) || uniswapV2Router02_ == address(0) || wgas_ == address(0)) {
            revert InvalidParameters();
        }

        uniswapV2Factory = IUniswapV2Factory(uniswapV2Factory_);
        uniswapV2Router02 = IUniswapV2Router02(uniswapV2Router02_);
        WGAS = wgas_;

        IWETH(WGAS).approve(uniswapV2Factory_, type(uint256).max);

        emit DexLuancherInitialized(uniswapV2Factory_, uniswapV2Router02_, wgas_);
    }

    function setOperator(address _operator, bool _isAllowed) external onlyOwner {
        _isOperator[_operator] = _isAllowed;
        emit OperatorUpdated(_operator, _isAllowed);
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                         COLLECT FEES                       *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function collectAllFees(address tk)
        external
        returns (address token0, uint256 amount0, address token1, uint256 amount1)
    {}

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                     CREATE AND MINT POOL                   *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function createAndMintLiquidity(
        address tk,
        uint256 tkAmountToMint,
        uint256 amountTkMin,
        uint256 amountGASMin
    )
        external
        payable
        onlyOperator
        returns (address pool, uint256 liquidity, uint256 amountToken, uint256 amountGAS)
    {
        pool = _createPool(tk);
        (liquidity, amountToken, amountGAS) = _mintLiquidity(tk, pool, tkAmountToMint, amountTkMin, amountGASMin);
    }

    /// @notice Creates and initializes liquidty pool
    /// @param tk: The token address
    /// @return pair_ The address of the liquidity pool created
    function _createPool(address tk) internal returns (address pair_) {
        _validateToken(tk);

        pair_ = uniswapV2Factory.createPair(tk, WGAS);
        if (pair_ == address(0)) {
            revert InvalidAddress();
        }

        emit PoolCreated(tk, pair_);
    }

    /// @notice Calls the mint function in periphery of uniswap v3, and refunds the exceeding parts.
    /// @param tk: The token address
    /// @param pool: The address of the liquidity pool to mint
    /// @param tkAmountToMint: The amount of token to mint
    /// @param amountTkMin: The minimum amount of tokens to mint in liqudity pool
    /// @param amountGASMin: The minimum amount of GAS to mint in liqudity pool
    /// @return liquidity The amount of liquidity for the position
    /// @return amountToken The amount of token1
    /// @return amountGAS The Address of token1
    function _mintLiquidity(
        address tk,
        address pool,
        uint256 tkAmountToMint,
        uint256 amountTkMin,
        uint256 amountGASMin
    )
        internal
        returns (uint256 liquidity, uint256 amountToken, uint256 amountGAS)
    {
        uint256 gasAmountToMint = msg.value;

        TransferHelper.safeTransferFrom(tk, msg.sender, address(this), tkAmountToMint);
        TransferHelper.safeApprove(tk, address(uniswapV2Router02), tkAmountToMint);

        (amountToken, amountGAS, liquidity) = uniswapV2Router02.addLiquidityETH{value: gasAmountToMint}(
            tk, tkAmountToMint, amountTkMin, amountGASMin, msg.sender, block.timestamp
        );
        emit PoolLiquidityMinted(tk, pool, amountToken, amountGAS, liquidity);

        // // Create a deposit
        // _createDeposit(msg.sender, tokenId);

        // // Remove allowance and refund in both assets.
        uint256 tokenRefund = _removeAllowanceAndRefundToken(tk, amountToken, tkAmountToMint);
        uint256 gasRefund = _removeAllowanceAndRefundToken(WGAS, amountGAS, gasAmountToMint);

        emit PoolLiquidityRefunded(pool, msg.sender, tk, tokenRefund, WGAS, gasRefund);
    }

    function _removeAllowanceAndRefundToken(
        address tk,
        uint256 amount,
        uint256 amountToMint
    )
        internal
        returns (uint256 refundAmount)
    {
        if (amount < amountToMint) {
            TransferHelper.safeApprove(tk, address(uniswapV2Router02), 0);
            refundAmount = amountToMint - amount;
            if (refundAmount > 1 ether) {
                TransferHelper.safeTransfer(tk, msg.sender, refundAmount);
            }
        }
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                       ERC721 RELATED                       *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    /// @notice Transfers funds to owner of NFT
    /// @param tokenId The id of the erc721
    /// @param amount0 The amount of token0
    /// @param amount1 The amount of token1
    function _sendToOwner(uint256 tokenId, uint256 amount0, uint256 amount1) private {
        // get owner of contract
        address owner = deposits[tokenId].owner;

        address token0 = deposits[tokenId].token0;
        address token1 = deposits[tokenId].token1;

        // send collected fees to owner
        TransferHelper.safeTransfer(token0, owner, amount0);
        TransferHelper.safeTransfer(token1, owner, amount1);
    }

    // function _createDeposit(address owner, uint256 tokenId) internal {
    //     (,, address token0, address token1,,,, uint128 liquidity,,,,) = uniswapPositionManager.positions(tokenId);
    //     // set the owner and data for position
    //     deposits[tokenId] = Deposit({owner: owner, liquidity: liquidity, token0: token0, token1: token1});
    // }

    function _validateToken(address tk) private pure {
        if (tk == address(0)) {
            revert InvalidAddress();
        }
    }

    receive() external payable {
        if (msg.sender != WGAS) {
            revert CannotReceiveETH();
        }
    }
}
