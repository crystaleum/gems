const AngelFactory = artifacts.require("AngelFactory");

module.exports = async function (deployer) {
  await deployer.deploy(AngelFactory);
};