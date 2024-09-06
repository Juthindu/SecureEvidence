
const Case = artifacts.require("Case");
const SecureEvidence = artifacts.require("SecureEvidence");
const SuperAdmin = artifacts.require("SuperAdmin");
const TypeAndId = artifacts.require("TypeAndId");
const User = artifacts.require("User");

module.exports = function (deployer) {
  deployer.deploy(Case);
  deployer.deploy(SecureEvidence);
  deployer.deploy(SuperAdmin);
  deployer.deploy(TypeAndId);
  deployer.deploy(User);
};
