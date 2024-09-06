// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SecureEvidence.sol";

contract Case is SecureEvidence {

        function addType(
        string memory _caseTypeID,
        string memory _description,
        string memory _category,
        uint8 _level
    ) public onlyLevelOne {
        require(bytes(_caseTypeID).length > 0, "Case type ID cannot be empty");
        require(!caseType[_caseTypeID], "Case type already exists");

        typesByID[_caseTypeID] = Type({
            caseTypeID: _caseTypeID,
            description: _description,
            category: _category,
            level: _level
        });

        caseType[_caseTypeID] = true;
        typeCount++;
    }

    function getType(
        string memory _caseTypeID) 
        public 
        view 
        onlyLevelOne 
        returns (
            string memory category, 
            uint8 level,
            string memory description) 
    {
        require(bytes(typesByID[_caseTypeID].caseTypeID).length != 0, "Case type not found");

        Type memory _type = typesByID[_caseTypeID];
        return (_type.category, _type.level,_type.description);
    }

    function addCase(
        string memory _caseTitle,
        string memory _caseID,
        string memory _caseTypeID,
        string memory _reportHash
    ) public onlyLevelOne {
        require(bytes(typesByID[_caseTypeID].caseTypeID).length != 0, "Case type does not exist");
        require(bytes(cases[_caseID].caseID).length == 0, "Case ID already exists");

        Case memory newCase = Case({
            caseTitle: _caseTitle,
            caseID: _caseID,
            caseTypeID: _caseTypeID,
            reportHash: _reportHash,
            addedBy: msg.sender,
            status: Status.Active
        });

        cases[_caseID] = newCase;
        caseCount++;
        casesByType[_caseTypeID].push(newCase);
    }

    function updateCaseStatus(
        string memory _caseID,
        Status _status
    ) public onlyLevelOne {
        require(bytes(cases[_caseID].caseID).length != 0, "Case does not exist");
        cases[_caseID].status = _status;
    }

    function getCase(string memory _caseID) 
        public 
        view 
        onlyLevelOne 
        returns (
            string memory caseTitle, 
            string memory caseTypeID, 
            string memory reportHash, 
            address addedBy, 
            Status status
        ) 
    {
        require(bytes(cases[_caseID].caseID).length != 0, "Case not found");

        Case memory _case = cases[_caseID];
        return (_case.caseTitle, _case.caseTypeID, _case.reportHash, _case.addedBy, _case.status);
    }

        function addEvidence(
        string memory _caseID, 
        string memory _evidenceID,
        string memory _evidenceType, 
        string memory _evidenceHash
        ) public onlyLevelTwo {
            require(bytes(cases[_caseID].caseID).length != 0, "Case does not exist");
            require(bytes(evidenceByID[_evidenceID].caseID).length == 0, "Evidence ID already exists");

            Evidence memory newEvidence = Evidence({
                caseID: _caseID,
                evidenceID: _evidenceID,
                evidenceType: _evidenceType,
                evidenceHash: _evidenceHash,
                addedBy: msg.sender,
                status: Status.Active
            });

            caseEvidence[_caseID].push(newEvidence);
            evidenceByID[_evidenceID] = newEvidence;
            evidenceIndexByID[_evidenceID] = caseEvidence[_caseID].length - 1;
            evidenceCount++;
            }

    function updateEvidenceStatus(
        string memory _caseID, 
        string memory  _evidenceID, 
        Status _status
        ) public onlyLevelOne {
            require(bytes(cases[_caseID].caseID).length != 0, "Case does not exist");
            require(bytes(evidenceByID[_evidenceID].caseID).length != 0, "Evidence does not exist");

            evidenceByID[_evidenceID].status = _status;

            uint256 evidenceIndex = evidenceIndexByID[_evidenceID];
            caseEvidence[_caseID][evidenceIndex].status = _status;
            }

    function getEvidence(
        string memory _caseID, 
        string memory _evidenceID 
        ) public view onlyLevelOne returns (
            string memory evidenceType, 
            string memory evidenceHash, 
            address addedBy, 
            Status status) {
                require(bytes(cases[_caseID].caseID).length != 0, "Case does not exist");
                require(bytes(evidenceByID[_evidenceID].caseID).length != 0, "Evidence does not exist");

                Evidence memory _evidence = evidenceByID[_evidenceID];
                return (_evidence.evidenceType, _evidence.evidenceHash, _evidence.addedBy, _evidence.status);
                }


}
