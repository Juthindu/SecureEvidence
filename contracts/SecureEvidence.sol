// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureEvidence {
    address private superAdminAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    string private superAdminUsername = "SuperAdmin";

    enum Status {Inactive, Active}
    enum UserRole {Admin, LevelOne, LevelTwo}
    event SuperAdminChanged(address oldSuperAdmin, address newSuperAdmin);
    event GuidelineHashUpdated(string newGuidelineHash, address updatedBy);


    struct Account {
        string name;
        uint256 ID;
        address accountAddress;
        string username;
        Status status;
        UserRole role;
    }

    struct Type {
        string caseType;
        string description;
        string category;
        uint8 level;
    }


    struct Case {
        string caseTitle;
        uint256 caseID;
        string caseType;
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

    mapping(address => Account) private accounts;
    mapping(uint256 => address) private accountIDs;
    mapping(uint256 => bool) private evidenceIDs;
    mapping(string => bool) private caseType;
    mapping(uint256 => Case) public cases;
    mapping(string => Type) public types;
    mapping(uint256 => Evidence[]) public caseEvidence;
    mapping(string => Case[]) private casesByType;


    
    uint256 public accountCount;
    uint256 public caseCount;
    uint256 public typeCount;
    uint256 public evidenceCount;
    string public  guidelineHash; 

    modifier onlySuperAdmin() {
        require(msg.sender == superAdminAddress, "Not SuperAdmin");
        _;
    }

    modifier onlyAdmin() {
        require(accounts[msg.sender].status == Status.Active &&
        accounts[msg.sender].role == UserRole.Admin ||
        msg.sender == superAdminAddress, "Not an active Admin");
        _;
    }

    modifier onlyLevelOne() {
        require(
            accounts[msg.sender].status == Status.Active &&
            (accounts[msg.sender].role == UserRole.Admin || accounts[msg.sender].role == UserRole.LevelOne) ||
            msg.sender == superAdminAddress, "Not an active Level 1 User");
            _;
    }

    modifier onlyLevelTwo() {
        require(
            accounts[msg.sender].status == Status.Active && 
            (accounts[msg.sender].role == UserRole.Admin || accounts[msg.sender].role == UserRole.LevelOne || accounts[msg.sender].role == UserRole.LevelTwo) || 
            msg.sender == superAdminAddress, 
            "Not an active Level 2 User"
        );
        _;
    }
    //done
    function login(string memory _username) public view returns (string memory) {
        address _account = msg.sender;

        if (_account == superAdminAddress && keccak256(abi.encodePacked(_username)) == keccak256(abi.encodePacked(superAdminUsername))) {
            return "Welcome SuperAdmin";
        } else if (accounts[_account].accountAddress != address(0) && keccak256(abi.encodePacked(accounts[_account].username)) == keccak256(abi.encodePacked(_username))) {
            if (accounts[_account].status == Status.Active) {
                if (accounts[_account].role ==UserRole.Admin){
                    return "Welcome Admin";
                }else if (accounts[_account].role ==UserRole.LevelOne){
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

    function changeSuperAdmin(address _newSuperAdmin) public onlySuperAdmin {
        require(_newSuperAdmin != address(0), "Invalid new SuperAdmin address");

        address _oldSuperAdmin = superAdminAddress;
        superAdminAddress = _newSuperAdmin;

        emit SuperAdminChanged(_oldSuperAdmin, _newSuperAdmin);
    }

    function setGuidelineHash(string memory _guidelineHash) public onlySuperAdmin {
        guidelineHash = _guidelineHash;
    }

    function updateGuidelineHash(string memory _newGuidelineHash) public onlySuperAdmin {
        guidelineHash = _newGuidelineHash;
        emit GuidelineHashUpdated(_newGuidelineHash, msg.sender);
    }


    //done
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
    //done
    function updateUser(uint256 _ID,string memory _name,address _accountAddress,string memory _username,Status _status,UserRole _role
    ) public onlyAdmin returns (string memory) {
        require(accounts[_accountAddress].accountAddress != address(0), "User does not exist");

        accounts[_accountAddress].name = _name;
        accounts[_accountAddress].ID = _ID;
        accounts[_accountAddress].username = _username;
        accounts[_accountAddress].status = _status;
        accounts[_accountAddress].role = _role;

        return "User updated successfully";
    }


    function addType(string memory _caseType, string memory _description, string memory _category, uint8 _level
    ) public onlyLevelOne returns (string memory){
            require(!caseType[_caseType], "Case type already exists");
            types[_caseType] = Type({
                caseType: _caseType,
                description: _description,
                category: _category,
                level: _level
            });
            caseType[_caseType] = true;
            typeCount++;
            return "Type added successfully";
    }


    function addCase(string memory _caseTitle,uint256 _caseID,string memory _caseType,string memory _reportHash) 
        public onlyLevelOne returns (string memory) {
        require(bytes(types[_caseType].caseType).length != 0, "Case type does not exist");
        require(cases[_caseID].caseID == 0, "Case ID already exists");

        // Add case to cases mapping
        cases[_caseID] = Case({
            caseTitle: _caseTitle,
            caseID: _caseID,
            caseType: _caseType,
            reportHash: _reportHash,
            addedBy: msg.sender,
            status: Status.Active
        });
        caseCount++;

        // Add case to casesByType mapping
        Case memory newCase = Case({
            caseTitle: _caseTitle,
            caseID: _caseID,
            caseType: _caseType,
            reportHash: _reportHash,
            addedBy: msg.sender,
            status: Status.Active
        });
        casesByType[_caseType].push(newCase);

        return "Case added successfully";
    }

    function getCaseByType(string memory _caseType) public onlyLevelTwo view returns (Case[] memory) {
    require(bytes(types[_caseType].caseType).length != 0, "Case type does not exist");
    return casesByType[_caseType]; 
    }

    //done
    function updateCaseStatus(uint256 _caseID,uint256 _caseTypeIndex,string memory _caseType, Status _status) 
    public onlyLevelOne {
        require(cases[_caseID].caseID != 0, "Case does not exist");
        require(_caseTypeIndex < casesByType[_caseType].length, "Invalid caseTypeIndex");
        cases[_caseID].status = _status;
        casesByType[_caseType][_caseTypeIndex].status = _status;
    }
    //done
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
        evidenceCount++;
        return "Evidence added successfully";
    }
    //done
    function updateEvidenceStatus(uint256 _caseID, uint256 _evidenceIndex, Status _status) 
    public onlyLevelOne {
        require(cases[_caseID].caseID != 0, "Case does not exist");
        require(_evidenceIndex < caseEvidence[_caseID].length, "Invalid evidence index");

        caseEvidence[_caseID][_evidenceIndex].status = _status;
    }
    //done
    function getEvidenceByCaseID(uint256 _caseID) 
    public onlyLevelOne view returns (Evidence[] memory) {
        require(cases[_caseID].caseID != 0, "Case does not exist");
        return caseEvidence[_caseID];
    }
    
    //done
    function getUserByID(uint256 _ID) 
    public view onlyLevelOne returns (Account memory) {
        address userAddress = accountIDs[_ID];
        require(userAddress != address(0), "Admin not found");
        require(accounts[userAddress].role == UserRole.LevelOne ||
        accounts[userAddress].role == UserRole.LevelTwo, "Not an user");

        return accounts[userAddress];
    }
    //done
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
