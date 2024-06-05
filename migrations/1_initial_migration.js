const SecureEvidence = artifacts.require("SecureEvidence");

module.exports = function(deployer) {
  deployer.deploy(SecureEvidence);
};
