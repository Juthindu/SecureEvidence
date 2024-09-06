// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SecureEvidence.sol";

contract TypeAndId is SecureEvidence {

    function getCaseByType(string memory _caseTypeID) public view onlyLevelTwo returns (
        string[] memory caseTitles,
        string[] memory caseIDs,
        string[] memory caseTypeIDs,
        string[] memory reportHashes,
        address[] memory addedBys,
        Status[] memory statuses
    ) {
        require(bytes(typesByID[_caseTypeID].caseTypeID).length != 0, "Case type does not exist");

        uint256 casesCount = casesByType[_caseTypeID].length;
        
        caseTitles = new string[](casesCount);
        caseIDs = new string[](casesCount);
        caseTypeIDs = new string[](casesCount);
        reportHashes = new string[](casesCount);
        addedBys = new address[](casesCount);
        statuses = new Status[](casesCount);

        for (uint256 i = 0; i < casesCount; i++) {
            Case memory _case = casesByType[_caseTypeID][i];
            caseTitles[i] = _case.caseTitle;
            caseIDs[i] = _case.caseID;
            caseTypeIDs[i] = _case.caseTypeID;
            reportHashes[i] = _case.reportHash;
            addedBys[i] = _case.addedBy;
            statuses[i] = _case.status;
        }

        return (caseTitles, caseIDs, caseTypeIDs, reportHashes, addedBys, statuses);
    }

    function getAllEvidenceByCaseID(string memory _caseID) public view onlyLevelOne returns (
        string[] memory caseIDs,
        string[] memory evidenceTypes,
        string[] memory evidenceHashes,
        address[] memory addedBys,
        Status[] memory statuses
    ) {
        require(bytes(cases[_caseID].caseID).length != 0, "Case does not exist");
        
        uint256 evidenceCount = caseEvidence[_caseID].length;
        
        caseIDs = new string[](evidenceCount);
        evidenceTypes = new string[](evidenceCount);
        evidenceHashes = new string[](evidenceCount);
        addedBys = new address[](evidenceCount);
        statuses = new Status[](evidenceCount);
        
        for (uint256 i = 0; i < evidenceCount; i++) {
            Evidence memory _evidence = caseEvidence[_caseID][i];
            caseIDs[i] = _evidence.caseID;
            evidenceTypes[i] = _evidence.evidenceType;
            evidenceHashes[i] = _evidence.evidenceHash;
            addedBys[i] = _evidence.addedBy;
            statuses[i] = _evidence.status;
        }
        
        return (caseIDs, evidenceTypes, evidenceHashes, addedBys, statuses);
    }
}
