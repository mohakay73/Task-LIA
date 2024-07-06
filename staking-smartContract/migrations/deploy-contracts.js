const TokenA = artifacts.require('TokenA');
const TokenB = artifacts.require('TokenB');
const StakingContract = artifacts.require('StakingContract');

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(TokenA);
  await deployer.deploy(TokenB);
  const tokenA = await TokenA.deployed();
  const tokenB = await TokenB.deployed();
  const rewardRate = web3.utils.toWei('1', 'ether'); // Set reward rate
  await deployer.deploy(
    StakingContract,
    tokenA.address,
    tokenB.address,
    rewardRate,
    { from: accounts[0] }
  );
};
