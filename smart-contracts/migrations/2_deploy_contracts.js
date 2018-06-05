let DiscoverBlockchainCrowdsale = artifacts.require("./DiscoverBlockchainCrowdsale.sol");

module.exports = function(deployer) {
    const startTime = Math.round((new Date().getTime())/1000); // Today
    const endTime = Math.round((new Date().getTime() + (86400000 * 20))/1000); // Today + 20 days
    deployer.deploy(DiscoverBlockchainCrowdsale,
        startTime,
        endTime,
        10000,
        '0xCB7fA6bac4Fbdc99543Cf06e64330928428dfCd8', // Replace this wallet address with the last one (10th account) from Ganache UI. This will be treated as the beneficiary address.
        10000000000000000000000, // 10000 ETH - Soft-cap
        60000000000000000000000 // 60000 ETH - Hard-cap
    );
};
