/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.6.6;

//import "zeppelin/token/ERC20/ERC20.sol";

//import "zeppelin/token/ERC20/ERC20.sol";
//import "../../installed_contracts/zeppelin/contracts/token/ERC20/IERC20.sol";
//import "zeppelin/token/ERC20/ERC20.sol";

// File: /home/seifer/Work/workshop/contracts/ERC20Interface.sol

// https://github.com/ethereum/EIPs/issues/20
interface KyberERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

// File: /home/seifer/Work/workshop/contracts/PermissionGroups.sol

contract PermissionGroups {

    address public admin;
    address public pendingAdmin;
    mapping(address=>bool) internal operators;
    mapping(address=>bool) internal alerters;
    address[] internal operatorsGroup;
    address[] internal alertersGroup;
    uint constant internal MAX_GROUP_SIZE = 50;


    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender]);
        _;
    }

    modifier onlyAlerter() {
        require(alerters[msg.sender]);
        _;
    }

    function getOperators () external view returns(address[] memory) {}

    function getAlerters () external view returns(address[] memory) {}

    event TransferAdminPending(address pendingAdmin);

    /**
     * @dev Allows the current admin to set the pendingAdmin address.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdmin(address newAdmin) public onlyAdmin {}

    /**
     * @dev Allows the current admin to set the admin in one tx. Useful initial deployment.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdminQuickly(address newAdmin) public onlyAdmin {
    }

    event AdminClaimed( address newAdmin, address previousAdmin);

    /**
     * @dev Allows the pendingAdmin address to finalize the change admin process.
     */
    function claimAdmin() public {

    }

    event AlerterAdded (address newAlerter, bool isAdd);

    function addAlerter(address newAlerter) public onlyAdmin {
    }

    function removeAlerter (address alerter) public onlyAdmin {

    }

    event OperatorAdded(address newOperator, bool isAdd);

    function addOperator(address newOperator) public onlyAdmin {

    }

    function removeOperator (address operator) public onlyAdmin {

    }
}

// File: /home/seifer/Work/workshop/contracts/Withdrawable.sol

/**
 * @title Contracts that should be able to recover tokens or ethers
 * @author Ilan Doron
 * @dev This allows to recover any tokens or Ethers received in a contract.
 * This will prevent any accidental loss of tokens.
 */
contract KyberWithdrawable is PermissionGroups {

    event TokenWithdraw(KyberERC20 token, uint amount, address sendTo);

    /**
     * @dev Withdraw all ERC20 compatible tokens
     * @param token ERC20 The address of the token contract
     */
    function withdrawToken(KyberERC20 token, uint amount, address sendTo) external onlyAdmin {

    }

    event EtherWithdraw(uint amount, address sendTo);

    /**
     * @dev Withdraw Ethers
     */
    function withdrawEther(uint amount, address sendTo) external onlyAdmin {

    }
}

// File: /home/seifer/Work/workshop/contracts/Utils.sol

/// @title Kyber constants contract
contract Utils {

    KyberERC20 constant internal ETH_TOKEN_ADDRESS = KyberERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    uint  constant internal PRECISION = (10**18);
    uint  constant internal MAX_QTY   = (10**28); // 10B tokens
    uint  constant internal MAX_RATE  = (PRECISION * 10**6); // up to 1M tokens per ETH
    uint  constant internal MAX_DECIMALS = 18;
    uint  constant internal ETH_DECIMALS = 18;
    mapping(address=>uint) internal decimals;

    function setDecimals(KyberERC20 token) internal {

    }

    function getDecimals(KyberERC20 token) internal view returns(uint) {

    }

    function calcDstQty(uint srcQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {

    }

    function calcSrcQty(uint dstQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {

    }
}

// File: /home/seifer/Work/workshop/contracts/Utils2.sol

contract Utils2 is Utils {

    /// @dev get the balance of a user.
    /// @param token The token type
    /// @return The balance
    function getBalance(KyberERC20 token, address user) public view returns(uint) {

    }

    function getDecimalsSafe(KyberERC20 token) internal returns(uint) {

    }

    function calcDestAmount(KyberERC20 src, KyberERC20 dest, uint srcAmount, uint rate) internal view returns(uint) {

    }

    function calcSrcAmount(KyberERC20 src, KyberERC20 dest, uint destAmount, uint rate) internal view returns(uint) {

    }

    function calcRateFromQty(uint srcAmount, uint destAmount, uint srcDecimals, uint dstDecimals)
    internal pure returns(uint)
    {

    }
}

// File: /home/seifer/Work/workshop/contracts/KyberNetworkInterface.sol

/// @title Kyber Network interface
interface KyberNetworkInterface {
    function maxGasPrice() external view returns(uint);
    function getUserCapInWei(address user) external view returns(uint);
    function getUserCapInTokenWei(address user, KyberERC20 token) external view returns(uint);
    function enabled() external view returns(bool);
    function info(bytes32 id) external view returns(uint);

    function getExpectedRate(KyberERC20 src, KyberERC20 dest, uint srcQty) external view
    returns (uint expectedRate, uint slippageRate);

    function tradeWithHint(address trader, KyberERC20 src, uint srcAmount, KyberERC20 dest, address destAddress,
        uint maxDestAmount, uint minConversionRate, address walletId, bytes calldata hint) external payable returns(uint);
}

// File: /home/seifer/Work/workshop/contracts/KyberNetworkProxyInterface.sol

/// @title Kyber Network interface
interface KyberNetworkProxyInterface {
    function maxGasPrice() external view returns(uint);
    function getUserCapInWei(address user) external view returns(uint);
    function getUserCapInTokenWei(address user, KyberERC20 token) external view returns(uint);
    function enabled() external view returns(bool);
    function info(bytes32 id) external view returns(uint);

    function getExpectedRate(KyberERC20 src, KyberERC20 dest, uint srcQty) external view
    returns (uint expectedRate, uint slippageRate);

    function tradeWithHint(KyberERC20 src, uint srcAmount, KyberERC20 dest, address destAddress, uint maxDestAmount,
        uint minConversionRate, address walletId, bytes calldata hint) external payable returns(uint);
}

// File: /home/seifer/Work/workshop/contracts/SimpleNetworkInterface.sol

/// @title simple interface for Kyber Network
interface SimpleNetworkInterface {
    function swapTokenToToken(KyberERC20 src, uint srcAmount, KyberERC20 dest, uint minConversionRate) external returns(uint);
    function swapEtherToToken(KyberERC20 token, uint minConversionRate) external payable returns(uint);
    function swapTokenToEther(KyberERC20 token, uint srcAmount, uint minConversionRate) external returns(uint);
}

// File: contracts/KyberNetworkProxy.sol

////////////////////////////////////////////////////////////////////////////////////////////////////////
/// @title Kyber Network proxy for main contract
contract KyberNetworkProxy is KyberNetworkProxyInterface, SimpleNetworkInterface, KyberWithdrawable, Utils2 {

    KyberNetworkInterface public kyberNetworkContract;

    constructor(address _admin) public {

    }

    /// @notice use token address ETH_TOKEN_ADDRESS for ether
    /// @dev makes a trade between src and dest token and send dest token to destAddress
    /// @param src Src token
    /// @param srcAmount amount of src tokens
    /// @param dest   Destination token
    /// @param destAddress Address to send tokens to
    /// @param maxDestAmount A limit on the amount of dest tokens
    /// @param minConversionRate The minimal conversion rate. If actual rate is lower, trade is canceled.
    /// @param walletId is the wallet ID to send part of the fees
    /// @return amount of actual dest tokens
    function trade(
        KyberERC20 src,
        uint srcAmount,
        KyberERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
    )
    public
    payable
    returns(uint)
    {

    }

    /// @dev makes a trade between src and dest token and send dest tokens to msg sender
    /// @param src Src token
    /// @param srcAmount amount of src tokens
    /// @param dest Destination token
    /// @param minConversionRate The minimal conversion rate. If actual rate is lower, trade is canceled.
    /// @return amount of actual dest tokens
    function swapTokenToToken(
        KyberERC20 src,
        uint srcAmount,
        KyberERC20 dest,
        uint minConversionRate
    )
    public override
    returns(uint)
    {

    }

    /// @dev makes a trade from Ether to token. Sends token to msg sender
    /// @param token Destination token
    /// @param minConversionRate The minimal conversion rate. If actual rate is lower, trade is canceled.
    /// @return amount of actual dest tokens
    function swapEtherToToken(KyberERC20 token, uint minConversionRate) public override payable returns(uint) {

    }

    /// @dev makes a trade from token to Ether, sends Ether to msg sender
    /// @param token Src token
    /// @param srcAmount amount of src tokens
    /// @param minConversionRate The minimal conversion rate. If actual rate is lower, trade is canceled.
    /// @return amount of actual dest tokens
    function swapTokenToEther(KyberERC20 token, uint srcAmount, uint minConversionRate) public override returns(uint) {

    }

    struct UserBalance {
        uint srcBalance;
        uint destBalance;
    }

    event ExecuteTrade(address indexed trader, KyberERC20 src, KyberERC20 dest, uint actualSrcAmount, uint actualDestAmount);

    /// @notice use token address ETH_TOKEN_ADDRESS for ether
    /// @dev makes a trade between src and dest token and send dest token to destAddress
    /// @param src Src token
    /// @param srcAmount amount of src tokens
    /// @param dest Destination token
    /// @param destAddress Address to send tokens to
    /// @param maxDestAmount A limit on the amount of dest tokens
    /// @param minConversionRate The minimal conversion rate. If actual rate is lower, trade is canceled.
    /// @param walletId is the wallet ID to send part of the fees
    /// @param hint will give hints for the trade.
    /// @return amount of actual dest tokens
    function tradeWithHint(
        KyberERC20 src,
        uint srcAmount,
        KyberERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId,
        bytes memory hint
    )
    public
    override
    payable
    returns(uint)
    {

    }

    event KyberNetworkSet(address newNetworkContract, address oldNetworkContract);

    function setKyberNetworkContract(KyberNetworkInterface _kyberNetworkContract) public onlyAdmin {

    }

    function getExpectedRate(KyberERC20 src, KyberERC20 dest, uint srcQty)
    public override view
    returns(uint expectedRate, uint slippageRate)
    {

    }

    function getUserCapInWei(address user) public override view returns(uint) {

    }

    function getUserCapInTokenWei(address user, KyberERC20 token) public override view returns(uint) {

    }

    function maxGasPrice() public override view returns(uint) {

    }

    function enabled() public override view returns(bool) {

    }

    function info(bytes32 field) public override view returns(uint) {

    }

    struct TradeOutcome {
        uint userDeltaSrcAmount;
        uint userDeltaDestAmount;
        uint actualRate;
    }

    function calculateTradeOutcome (uint srcBalanceBefore, uint destBalanceBefore, KyberERC20 src, KyberERC20 dest,
        address destAddress)
    internal returns(TradeOutcome memory outcome)
    {

    }
}
