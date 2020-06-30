const KyberSwapTokenToToken = artifacts.require('./Kyber/KyberSwapTokenToToken.sol');
const Uni1ToUni2Dai = artifacts.require('./arbitrage/Uni1ToUni2Dai.sol');
const Uni2ToUni1Dai = artifacts.require('./arbitrage/Uni2ToUni1Dai.sol');


module.exports = async function(deployer) {
    // kovan for now
   await deployer.deploy(KyberSwapTokenToToken, '0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D');
   // Uniswap below is all mainnet
   await deployer.deploy(Uni1ToUni2Dai);
   await deployer.deploy(Uni2ToUni1Dai);


};
