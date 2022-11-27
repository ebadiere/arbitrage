pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/Counter.sol";

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolState.sol";

contract UniswapV3FeaturesTest is Test {

    address private constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address private constant SHIB = 0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IUniswapV3Factory iUniswapV3Factory;
    IUniswapV3PoolState iUniswapV3PoolState;

    // Pool fee tiers
    uint24 public constant stablePoolTier = 500;
    uint24 public constant mediumRiskTier = 3000;
    uint24 public constant highRiskTier = 10000; 

    uint160 sqrtPriceX96;     

    function setUp() public {
        iUniswapV3Factory = IUniswapV3Factory(FACTORY);
    }

    function testGetShibEthPoolAddresses() public {
        
        address zeroPointFivePoolAddr = iUniswapV3Factory.getPool(SHIB, WETH, stablePoolTier);
        console.log("0.05 tier address: ", zeroPointFivePoolAddr);

        iUniswapV3PoolState = IUniswapV3PoolState(zeroPointFivePoolAddr);
        (sqrtPriceX96,,,,,,) = iUniswapV3PoolState.slot0();
        console.log("sqrtPriceX96: ", sqrtPriceX96);
        

    }

} 