const StakingContract = artifacts.require('StakingContract');
const TokenA = artifacts.require('TokenA');
const TokenB = artifacts.require('TokenB');

module.exports = async function (deployer) {
  await deployer.deploy(TokenA);
  await deployer.deploy(TokenB);
  await deployer.deploy(StakingContract, TokenA.address, TokenB.address);
};
