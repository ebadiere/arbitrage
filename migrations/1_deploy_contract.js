const Uni1KyberArbitrageur = artifacts.require('./arbitrage/Uni1KyberArbitrageur.sol');

module.exports = async function(deployer) {
    // kovan for now
   await deployer.deploy(Uni1KyberArbitrageur);

};
