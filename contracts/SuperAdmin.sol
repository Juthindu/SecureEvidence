// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SecureEvidence.sol";

contract SuperAdmin is SecureEvidence {
    function changeSuperAdmin(
        address _newSuperAdmin, 
        string memory _newSuperAdminUsername) public onlySuperAdmin {
        require(_newSuperAdmin != address(0), "Invalid new SuperAdmin address");
        require(bytes(_newSuperAdminUsername).length > 0, "Invalid new SuperAdmin username");

        address _oldSuperAdmin = superAdminAddress;
        string memory _oldSuperAdminUsername = superAdminUsername;

        superAdminAddress = _newSuperAdmin;
        superAdminUsername = _newSuperAdminUsername;

        emit SuperAdminChanged(_oldSuperAdmin, _oldSuperAdminUsername, _newSuperAdmin, _newSuperAdminUsername);
    }

    function setGuidelineHash(string memory _guidelineHash) public onlySuperAdmin {
        guidelineHash = _guidelineHash;
    }

    function updateGuidelineHash(string memory _newGuidelineHash) public onlySuperAdmin {
        guidelineHash = _newGuidelineHash;
        emit GuidelineHashUpdated(_newGuidelineHash, msg.sender);
    }

}
