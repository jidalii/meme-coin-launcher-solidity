// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

import "@uniswap/swap-router/interfaces/ISwapRouter02.sol";
import "@uniswap/swap-router/interfaces/IV3SwapRouter.sol";

import "../src/token/interfaces/IWETH.sol";

contract Swap {
    ISwapRouter02 public constant swapRouter = ISwapRouter02(0xB971eF87ede563556b2ED4b1C0b0019111Dd85d2);

    address public immutable WGAS;
    address public immutable TOKEN;

    // For this example, we will set the pool fee to 1%.
    uint24 public constant poolFee = 10_000;

    constructor(address _wgas, address _token) {
        WGAS = _wgas;
        TOKEN = _token;
    }

    function swapETHForTokens() external payable returns (uint256 amountOut) {
        uint256 amountIn = msg.value;
        IWETH(WGAS).deposit{value: amountIn}();

        // Approve the router to spend TOKEN.
        TransferHelper.safeApprove(WGAS, address(swapRouter), amountIn);

        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
            tokenIn: WGAS,
            tokenOut: TOKEN,
            fee: poolFee,
            recipient: msg.sender,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        amountOut = swapRouter.exactInputSingle(params);
    }

    function swapTokenForETH(uint256 amountIn) external returns (uint256 amountOut) {
        TransferHelper.safeTransferFrom(TOKEN, msg.sender, address(this), amountIn);

        // Approve the router to spend TOKEN.
        TransferHelper.safeApprove(TOKEN, address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
            tokenIn: TOKEN,
            tokenOut: WGAS,
            fee: poolFee,
            recipient: msg.sender,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }
}
