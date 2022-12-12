pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/Counter.sol";

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolState.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";

contract UniswapV3FeaturesTest is Test {

    address private constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address private constant QUOTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
    address private constant SHIB = 0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IQuoter iQuoter;
    IUniswapV3Factory iUniswapV3Factory;
    IUniswapV3PoolState iUniswapV3PoolState;

    // Pool fee tiers
    uint24 public constant stablePoolTier = 500;
    uint24 public constant mediumRiskTier = 3000;
    uint24 public constant highRiskTier = 10000; 

    uint160 sqrtPriceX96;     

    function setUp() public {
        iUniswapV3Factory = IUniswapV3Factory(FACTORY);
        iQuoter = IQuoter(QUOTER);
    }

    function testGetShibEthPoolAddresses() public {
        console.log("sqrtPriceX96: ", getSqrtPriceX96(SHIB, WETH, stablePoolTier));   
    }

    function testQuoteExactInputSingle() public {
        console.log("Test quoteExactInputSingle!");
        uint256 amountIn = 1000 * 1e18;
        uint256 amountOut = iQuoter.quoteExactInputSingle(SHIB, WETH, mediumRiskTier, amountIn, 0);
        console.log("Amount Out: ", amountOut);
    
    }

    function getSqrtPriceX96(address tokenIn, address tokenOut, uint24 tier) internal returns (uint160 sqrtPrice){
        address zeroPointFivePoolAddr = iUniswapV3Factory.getPool(tokenIn, tokenOut, tier);
        console.log("0.05 tier address: ", zeroPointFivePoolAddr);

        iUniswapV3PoolState = IUniswapV3PoolState(zeroPointFivePoolAddr);
        (sqrtPrice,,,,,,) = iUniswapV3PoolState.slot0();
        return sqrtPrice;
    }

} 