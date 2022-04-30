const GemFactory = artifacts.require("GemFactory");

module.exports = async function (deployer) {
  await deployer.deploy(GemFactory);
};
