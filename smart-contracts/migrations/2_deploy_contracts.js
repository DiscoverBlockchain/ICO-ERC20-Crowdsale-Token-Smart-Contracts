/* NOTE: Use this file to easily deploy the contracts you're writing.
 * Make sure to reset this file before committing
 * with `git checkout HEAD -- migrations/2_deploy_contracts.js`
 */
const migrations = artifacts.require('./Migrations.sol');

module.exports = async (deployer) => {
    return deployer.deploy(
      migrations
    )
};
