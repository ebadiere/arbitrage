const KyberSwapTokenToToken = artifacts.require('./Kyber/KyberSwapTokenToToken.sol');
// const Arbitrageur           = artifacts.require('./Arbitrageur.sol');

module.exports = function(deployer) {
    // kovan for now
   deployer.deploy(KyberSwapTokenToToken, '0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D');
   // deployer.deploy(Arbitrageur);
};
