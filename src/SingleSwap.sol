// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract SingleSwap {

    ISwapRouter public immutable swapRouter;
    
    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }    

    function swapExactInputSingle(
        address tokenIn, 
        address tokenOut,
        address sender, 
        address recipient,
        uint24 poolFee,
        uint256 amountIn) external returns (uint256 amountOut) {
        
        TransferHelper.safeTransferFrom(tokenIn, sender, address(this), amountIn);

        TransferHelper.safeApprove(tokenIn, address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: recipient,
                deadline: block.timestamp + 10,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });       

        // The call to `exactInputSingle` executes the swap.
        return swapRouter.exactInputSingle(params);        
    }

}