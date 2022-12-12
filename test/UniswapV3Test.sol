// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/SingleSwap.sol";



/// @title An ERC-20 compatible ShameCoin.
/// @author Gabriel Fior
/// @dev Functions deviate from ERC20, see specific comments on each function.
contract Uniswapv3Test is Test {
    //using PoolAddress for address;
    ISwapRouter public swapRouter;
    IERC20 public dai;
    SingleSwap singleSwap;

    address owner;
    address luckyUser;
    address ZERO_ADDRESS = address(0);


    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant BUSD = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;

    // ToDo - Retrieve pool fees dynamically
    uint24 public constant poolFeeDAIUSDC = 3000;
    uint24 public constant poolFeeDAIBUSD = 500;

    function setUp() public {
        address swapRouterAddr = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
        swapRouter = ISwapRouter(swapRouterAddr);
        owner = address(this);
        luckyUser = vm.addr(2);
        dai = IERC20(DAI);

        singleSwap = new SingleSwap(swapRouter);
    }

    function testSwapExactInputSingleDAItoUSDC() public {
        // msg.sender must approve this contract
        address binanceUser = 0xDFd5293D8e347dFe59E90eFd55b2956a1343963d;
        vm.startPrank(binanceUser);

        dai.approve(address(this), 1000 * 1e18);
        console.log("approved");

        uint256 amountIn = 1e18;        

        // Approve the router to spend DAI.
        TransferHelper.safeApprove(DAI, address(swapRouter), amountIn);
        console.log("approved contract");

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: DAI,
                tokenOut: USDC,
                fee: poolFeeDAIUSDC,
                recipient: luckyUser,
                deadline: block.timestamp + 10,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });       

        // The call to `exactInputSingle` executes the swap.
        uint256 amountOut = swapRouter.exactInputSingle(params);
        
        console.log("executed swap, amount out", amountOut);

        vm.stopPrank();

        // test
        uint256 finalBalanceDAI = IERC20(DAI).balanceOf(binanceUser);
        console.log(
            "new usdc balance lucky user",
            IERC20(USDC).balanceOf(luckyUser)
        );
        assertEq(amountOut, IERC20(USDC).balanceOf(luckyUser));
    }

    function testSwapExactInputSingleDAItoBUSD() public {
        address binanceUser = 0xDFd5293D8e347dFe59E90eFd55b2956a1343963d;
        vm.startPrank(binanceUser);

        console.log("original dai balance", IERC20(DAI).balanceOf(binanceUser));

        dai.approve(address(this), 1000 * 1e18);
        console.log("approved");

        uint256 amountIn = 1e18;        

        // Approve the router to spend DAI.
        TransferHelper.safeApprove(DAI, address(swapRouter), amountIn);
        console.log("approved contract");

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: DAI,
                tokenOut: BUSD,
                fee: poolFeeDAIBUSD,
                recipient: luckyUser,
                deadline: block.timestamp + 10,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });       

        // The call to `exactInputSingle` executes the swap.
        uint256 amountOut = swapRouter.exactInputSingle(params);
        console.log("executed swap, amount out", amountOut);

        vm.stopPrank();

        console.log("final dai balance", IERC20(DAI).balanceOf(binanceUser));
        console.log(
            "new busd balance lucky user",
            IERC20(BUSD).balanceOf(luckyUser)
        );
        assertEq(amountOut, IERC20(BUSD).balanceOf(luckyUser));
    }

   function testSwapExactInputSingleContractDAItoUSDC() public {    

        address binanceUser = 0xDFd5293D8e347dFe59E90eFd55b2956a1343963d;
        vm.startPrank(binanceUser);

        console.log("singleSwap address: ", address(singleSwap));

        dai.approve(address(singleSwap), 1000 * 1e18);
        console.log("approved");

        uint256 amountIn = 1000 * 1e18; 

        uint256 amountOut = singleSwap.swapExactInputSingle(
            DAI,
            USDC,
            binanceUser,
            luckyUser,
            poolFeeDAIUSDC,
            amountIn
        );   

        console.log("Amount out: ", amountOut); 
        vm.stopPrank();

   }
}