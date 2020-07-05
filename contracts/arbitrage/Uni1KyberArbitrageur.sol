pragma solidity ^0.6.6;

import "../../installed_contracts/zeppelin/contracts/math/SafeMath.sol";
import "../../installed_contracts/zeppelin/contracts/token/ERC20/IERC20.sol";
import "../../installed_contracts/zeppelin/contracts/token/ERC20/SafeERC20.sol";
import "../aave/FlashLoanReceiverBase.sol";
import "../aave/ILendingPool.sol";
import "./interfaces/IUniswap.sol";
import "../Kyber/KyberNetworkProxy.sol";


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
 * kyberswap  factory: 0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D
 * Dai: 0xC4375B7De8af5a38a93548eb8453a498222C4fF2
 *
 * Mainnet addresses:
 * aave lending provider: 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8
 * uniswap 1 factory: 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95
 * uniswap 2 factory: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
 */
contract Uni1KyberArbitrageur is
FlashLoanReceiverBase(address(0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5))
{
    event Swap(address indexed sender, KyberERC20 srcToken, KyberERC20 destToken, uint amount);

    // still kovan addresses for now
    address public constant DAI_ADDRESS = 0xC4375B7De8af5a38a93548eb8453a498222C4fF2;
    address public constant UNISWAP_1_FACTORY = 0xECc6C0542710a0EF07966D7d1B10fA38bbb86523;
    address public constant KYBERSWAP_PROXY = 0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D;

    address public tokenAddress;

    KyberERC20 constant internal ETH_TOKEN_ADDRESS = KyberERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    ILendingPool public lendingPool;
    IUniswapExchange public uniSwap1Exchange;
    IUniswapExchange public exchangeB;
    IUniswapFactory public uniswapOneFactory;

    KyberNetworkProxy public proxy;

    constructor() public {
        // Instantiate Uniswap Factory A
        uniswapOneFactory = IUniswapFactory(UNISWAP_1_FACTORY);
        // get Exchange A Address
        address uni1Exchange_address = uniswapOneFactory.getExchange(DAI_ADDRESS);
        // Instantiate Exchange A
        uniSwap1Exchange = IUniswapExchange(uni1Exchange_address);

        //Instantiate KyberSwap proxy
        proxy = KyberNetworkProxy(KYBERSWAP_PROXY);

        // get lendingPoolAddress
        address lendingPoolAddress = addressesProvider.getLendingPool();
        //Instantiate Aaave Lending Pool B
        lendingPool = ILendingPool(lendingPoolAddress);
    }

    /*
     * Start the arbitrage
     */
    function makeArbitrage(uint256 amount, KyberERC20 token) public onlyOwner {
        bytes memory data = "";
        tokenAddress = address (token);

        KyberERC20 dai = KyberERC20(DAI_ADDRESS);
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

        KyberERC20 dai = KyberERC20(DAI_ADDRESS);
        KyberERC20 token = KyberERC20(tokenAddress);

        // Buying ETH at Exchange A
        require(
            dai.approve(address(uniSwap1Exchange), _amount),
            "Could not approve DAI sell"
        );

        uint256 tokenBought = uniSwap1Exchange.tokenToTokenSwapInput(
            _amount,
            1,
            1,
            deadline,
            tokenAddress
        );

        require(
            token.approve(address(proxy), tokenBought),
            "Could not approve token sell"
        );

        execSwap(token, tokenBought, dai, address(this));

        uint256 daiBought = address(this).balance;

        // Repay loan
        uint256 totalDebt = _amount.add(_fee);

        require(daiBought > totalDebt, "Did not profit");

        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }

    function getDeadline() internal view returns (uint256) {
        return now + 3000;
    }

    function execSwap(KyberERC20 srcToken, uint srcQty, KyberERC20 destToken, address destAddress) public {
        uint minConversionRate;

        // Check that the token transferFrom has succeeded
        require(srcToken.transferFrom(msg.sender, address(this), srcQty));

        // Mitigate ERC20 Approve front-running attack, by initially setting
        // allowance to 0
        require(srcToken.approve(address(proxy), 0));

        // Set the spender's token allowance to tokenQty
        require(srcToken.approve(address(proxy), srcQty));

        // Get the minimum conversion rate
        (minConversionRate,) = proxy.getExpectedRate(srcToken, ETH_TOKEN_ADDRESS, srcQty);

        // Swap the ERC20 token to ERC20
        uint destAmount = proxy.swapTokenToToken(srcToken, srcQty, destToken, minConversionRate);

        // Send the swapped tokens to the destination address
        require(destToken.transfer(destAddress, destAmount));
        // Log the event
        emit Swap(msg.sender, srcToken, destToken, destAmount);
    }
}
