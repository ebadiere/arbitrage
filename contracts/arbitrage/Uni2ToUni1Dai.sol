pragma solidity ^0.6.6;

import "../aave/FlashLoanReceiverBase.sol";
import "../aave/ILendingPool.sol";
import "./interfaces/IUniswap.sol";


//1 DAI = 1000000000000000000 (18 decimals)
/*
 * Arbitrageur is a contract to simulate the usage of flashloans
 * to make profit out of a market inbalacement
 *
 * For this example we deployed 2 Uniswap instances which we'll
 * call by ExchangeA and ExchangeB
 *
 * The steps happens as following:
 * 1. Borrow DAI from Aave
 * 2. Buy BAT with DAI on ExchangeA
 * 3. Sell BAT for DAI on ExchangeB
 * 4. Repay Aave loan
 * 5. Keep the profits
 * Kovan addresses:
 * aave lending provider: 0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5
 * uniswap 1 factory: 0xD3E51Ef092B2845f10401a0159B2B96e8B6c3D30
 * uniswap 2 factory: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
 *
 * Mainnet addresses:
 * aave lending provider: 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8
 * uniswap 1 factory: 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95
 * uniswap 2 factory: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
 */
contract Uni2ToUni1Dai is
FlashLoanReceiverBase(address(0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5))
{
    address public constant DAI_ADDRESS = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
    address public constant UNISWAP_1_FACTORY = 0xECc6C0542710a0EF07966D7d1B10fA38bbb86523;
    address public constant UNISWAP_2_FACTORY = 0x54Ac34e5cE84C501165674782582ADce2FDdc8F4;

    address public tokenAddress;

    ILendingPool public lendingPool;
    IUniswapExchange public exchangeUniOne;
    IUniswapExchange public exchangeUniTwo;
    IUniswapFactory public uniswapFactoryUniOne;
    IUniswapFactory public uniswapFactoryUniTwo;

    constructor() public {

        //Instantiate Uniswap Factory B
        uniswapFactoryUniTwo = IUniswapFactory(UNISWAP_2_FACTORY);
        // get Exchange B Address
        address exchangeB_address = uniswapFactoryUniTwo.getExchange(DAI_ADDRESS);
        //Instantiate Exchange B
        exchangeUniTwo = IUniswapExchange(exchangeB_address);

        // Instantiate Uniswap Factory A
        uniswapFactoryUniOne = IUniswapFactory(UNISWAP_1_FACTORY);

        // get lendingPoolAddress
        address lendingPoolAddress = addressesProvider.getLendingPool();
        //Instantiate Aaave Lending Pool B
        lendingPool = ILendingPool(lendingPoolAddress);
    }

    /*
     * Start the arbitrage
     */
    function makeArbitrage(uint256 amount, ERC20 token) public onlyOwner {
        bytes memory data = "";
        tokenAddress = address (token);

        // get Exchange A Address
        address exchangeA_address = uniswapFactoryUniOne.getExchange(tokenAddress);
        // Instantiate Exchange A
        exchangeUniOne = IUniswapExchange(exchangeA_address);

        ERC20 dai = ERC20(DAI_ADDRESS);
        lendingPool.flashLoan(address(this), DAI_ADDRESS, amount, data);

        // Any left amount of DAI is considered profit
        uint256 profit = dai.balanceOf(address(this));
        // Sending back the profits
        require(
            dai.transfer(msg.sender, profit),
            "Could not transfer back the profit"
        );
    }

    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params
    ) override external {
        // If transactions are not mined until deadline the transaction is reverted
        uint256 deadline = getDeadline();

        ERC20 dai = ERC20(DAI_ADDRESS);
        ERC20 token = ERC20(tokenAddress);

        // Buying ETH at Exchange A
        require(
            dai.approve(address(exchangeUniTwo), _amount),
            "Could not approve DAI sell"
        );

        uint256 tokenBought = exchangeUniTwo.tokenToTokenSwapInput(
            _amount,
            1,
            1,
            deadline,
            tokenAddress
        );

        require(
            token.approve(address(exchangeUniOne), tokenBought),
            "Could not approve DAI sell"
        );

        // Selling ETH at Exchange B
        uint256 daiBought = exchangeUniOne.tokenToTokenSwapInput(
            tokenBought,
            1,
            1,
            deadline,
            DAI_ADDRESS
        );

        // Repay loan
        uint256 totalDebt = _amount.add(_fee);

        require(daiBought > totalDebt, "Did not profit");

        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }

    function getDeadline() internal view returns (uint256) {
        return now + 3000;
    }
}
