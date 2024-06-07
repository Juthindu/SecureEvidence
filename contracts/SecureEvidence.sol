// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureEvidence {
    address public superAdminAddress = 0xC1c05FC13391ac717CF5DeB109B651Dd5115F274;
    string public superAdminUsername = "SuperAdmin";

    enum Status {Inactive, Active}
    enum UserRole {Admin, Level1, Level2}

    struct Account {
        string name;
        uint256 ID;
        address accountAddress;
        string username;
        Status status;
        UserRole role;
    }

    struct Case {
        string caseTitle;
        uint256 caseID;
        string caseType;
        uint8 caseLevel; // 1 for Level 1, 2 for Level 2
        string reportHash;
        address addedBy;
        Status status;
    }

    struct Evidence {
        uint256 caseID;
        string evidenceType;
        string evidenceHash;
        address addedBy;
        Status status;
    }

    mapping(address => Account) public accounts;
    mapping(uint256 => address) private accountIDs;
    mapping(uint256 => Case) public cases;
    mapping(uint256 => Evidence[]) public caseEvidence;

    uint256 public accountCount;
    uint256 public caseCount;

    modifier onlySuperAdmin() {
        require(msg.sender == superAdminAddress, "Not SuperAdmin");
        _;
    }

    modifier onlyAdmin() {
        require(accounts[msg.sender].status == Status.Active && accounts[msg.sender].role == UserRole.Admin || msg.sender == superAdminAddress, "Not an active Admin");
        _;
    }

    modifier onlyLevelOne() {
        require(accounts[msg.sender].status == Status.Active && accounts[msg.sender].role == UserRole.Level1 || accounts[msg.sender].role == UserRole.Admin || msg.sender == superAdminAddress, "Not an active Level 1 User");
        _;
    }

    modifier onlyLevelTwo() {
        require(accounts[msg.sender].status == Status.Active && accounts[msg.sender].role == UserRole.Level2 ||accounts[msg.sender].role == UserRole.Level1 || accounts[msg.sender].role == UserRole.Admin || msg.sender == superAdminAddress, "Not an active Level 2 User");
        _;
    }

    function login(string memory _username) public view returns (string memory) {
        address _account = msg.sender;

        if (_account == superAdminAddress && keccak256(abi.encodePacked(_username)) == keccak256(abi.encodePacked(superAdminUsername))) {
            return "Welcome SuperAdmin";
        } else if (accounts[_account].accountAddress != address(0) && keccak256(abi.encodePacked(accounts[_account].username)) == keccak256(abi.encodePacked(_username))) {
            if (accounts[_account].status == Status.Active) {
                if (accounts[_account].role ==UserRole.Admin){
                    return "Welcome Admin";
                }else if (accounts[_account].role ==UserRole.Level1){
                    return "Welcome User";
                }else{
                    return "Welcome";
                }
            } else {
                return "You cannot login, please contact Admin or SuperAdmin";
            }
        }
        return "User not registered";
    }

    function addNewUser(string memory _name,uint256 _ID,address _accountAddress,string memory _username,Status _status,UserRole _role
    ) public onlyAdmin returns (string memory) {
        require(accounts[_accountAddress].accountAddress == address(0), "User already exists");

        accounts[_accountAddress] = Account({
            name: _name,
            ID: _ID,
            accountAddress: _accountAddress,
            username: _username,
            status: _status,
            role: _role
        });

        accountIDs[_ID] = _accountAddress;
        accountCount++;

        return "User created successfully";
    }

    function updateUser(
        uint256 _ID,
        string memory _name,
        address _accountAddress,
        string memory _username,
        Status _status
    ) public onlyAdmin returns (string memory) {
        require(accounts[_accountAddress].accountAddress != address(0), "User does not exist");
        require(accounts[_accountAddress].role != UserRole.Admin || msg.sender == superAdminAddress, "Cannot update Admin role");

        accounts[_accountAddress].name = _name;
        accounts[_accountAddress].ID = _ID;
        accounts[_accountAddress].username = _username;
        accounts[_accountAddress].status = _status;

        return "User updated successfully";
    }

    function addCase(string memory _caseTitle, uint256 _caseID, string memory _caseType, uint8 _caseLevel, string memory _reportHash) 
    public onlyLevelOne returns (string memory) {
        require(_caseLevel == 1 || _caseLevel == 2, "Invalid case level");

        cases[_caseID] = Case({
            caseTitle: _caseTitle,
            caseID: _caseID,
            caseType: _caseType,
            caseLevel: _caseLevel,
            reportHash: _reportHash,
            addedBy: msg.sender,
            status: Status.Active
        });

        caseCount++;

        return "Case added successfully";
    }

    function updateCaseStatus(uint256 _caseID, Status _status) 
    public onlyLevelOne {
        require(cases[_caseID].caseID != 0, "Case does not exist");

        cases[_caseID].status = _status;
    }

    function addEvidence(uint256 _caseID, string memory _evidenceType, string memory _evidenceHash) 
    public onlyLevelTwo returns (string memory) {
        require(cases[_caseID].caseID != 0, "Case does not exist");

        Evidence memory newEvidence = Evidence({
            caseID: _caseID,
            evidenceType: _evidenceType,
            evidenceHash: _evidenceHash,
            addedBy: msg.sender,
            status: Status.Active
        });

        caseEvidence[_caseID].push(newEvidence);

        return "Evidence added successfully";
    }

    function updateEvidenceStatus(uint256 _caseID, uint256 _evidenceIndex, Status _status) 
    public onlyLevelOne {
        require(cases[_caseID].caseID != 0, "Case does not exist");
        require(_evidenceIndex < caseEvidence[_caseID].length, "Invalid evidence index");

        caseEvidence[_caseID][_evidenceIndex].status = _status;
    }

    function getEvidenceByCaseID(uint256 _caseID) 
    public onlyLevelOne view returns (Evidence[] memory) {
        require(cases[_caseID].caseID != 0, "Case does not exist");
        return caseEvidence[_caseID];
    }

    function getUserByID(uint256 _ID) 
    public view onlyAdmin returns (Account memory) {
        address userAddress = accountIDs[_ID];
        require(userAddress != address(0), "Admin not found");
        require(accounts[userAddress].role == UserRole.Level1 || accounts[userAddress].role == UserRole.Level2, "Not an user");

        return accounts[userAddress];
    }


    function getAdminByID(uint256 _ID) 
    public view onlyAdmin returns (Account memory) {
        address adminAddress = accountIDs[_ID];
        require(adminAddress != address(0), "Admin not found");
        require(accounts[adminAddress].role == UserRole.Admin, "Not an admin");

        return accounts[adminAddress];
    }

    function addressToIndex(uint256 _id) private view returns (address) {
        return accountIDs[_id];
    }
}


