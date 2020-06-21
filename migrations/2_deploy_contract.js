const KyberSwapContract                         = artifacts.require("KyberSwapContract");
const KyberNetworkProxy                         = artifacts.require("KyberNetworkProxy");
const PermissionGroups                          = artifacts.require("PermissionGroups");
const Utils                                     = artifacts.require("Utils");
const Utils2                                    = artifacts.require("Utils2");
const Withdrawable                              = artifacts.require("Withdrawable");


module.exports = function(deployer) {
    deployer.deploy(KyberSwapContract);

};