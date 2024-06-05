// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureEvidence {
    address public superAdminAddress = 0x546d61e9E3bce47133F7cC4f224cA17d4020fD6c;
    string public superAdminUsername = "SuperAdmin";

    enum Status {Inactive, Active}

    struct Admin {
        string name;
        uint256 ID;
        address accountAddress;
        string username;
        Status status;
    }

    struct User {
        string name;
        uint256 ID;
        uint8 userLevel; // 1 for Level 1, 2 for Level 2
        address accountAddress;
        string username;
        Status status;
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

    mapping(address => Admin) public admins;
    mapping(address => User) public users;
    mapping(uint256 => address) private adminIDs;
    mapping(uint256 => address) private userIDs;
    mapping(uint256 => Case) public cases;
    mapping(uint256 => Evidence[]) public caseEvidence;

    uint256 public adminCount;
    uint256 public userCount;

    modifier onlySuperAdmin() {
        require(msg.sender == superAdminAddress, "Not SuperAdmin");
        _;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender].status == Status.Active || msg.sender == superAdminAddress, "Not an active Admin or SuperAdmin");
        _;
    }

    modifier onlyLevelOne() {
        require(
            msg.sender == superAdminAddress ||
            (admins[msg.sender].status == Status.Active) ||
            (users[msg.sender].status == Status.Active && users[msg.sender].userLevel == 1),
            "Not authorized"
        );
        _;
    }

    modifier onlyLevelTwo() {
        require(
            msg.sender == superAdminAddress ||
            (admins[msg.sender].status == Status.Active) ||
            (users[msg.sender].status == Status.Active && (users[msg.sender].userLevel == 1 || users[msg.sender].userLevel == 2)),
            "Not authorized"
        );
        _;
    }

    function login(string memory _username) public view returns (string memory) {
        address _account = msg.sender;

        if (_account == superAdminAddress && keccak256(abi.encodePacked(_username)) == keccak256(abi.encodePacked(superAdminUsername))) {
            return "Welcome SuperAdmin";
        } else if (admins[_account].accountAddress != address(0) && keccak256(abi.encodePacked(admins[_account].username)) == keccak256(abi.encodePacked(_username))) {
            if (admins[_account].status == Status.Active) {
                return "Welcome Admin";
            } else {
                return "You cannot login, please contact Admin or SuperAdmin";
            }
        } else if (users[_account].accountAddress != address(0) && keccak256(abi.encodePacked(users[_account].username)) == keccak256(abi.encodePacked(_username))) {
            if (users[_account].status == Status.Active) {
                if (users[_account].userLevel == 1) {
                    return "Welcome L1 User";
                } else if (users[_account].userLevel == 2) {
                    return "Welcome L2 User";
                }
            } else {
                return "You cannot login, please contact Admin or SuperAdmin";
            }
        }
        return "User not registered";
    }

    function addAdmin(string memory _name, uint256 _ID, address _accountAddress, string memory _username, Status _status) public onlySuperAdmin returns (string memory){
        require(admins[_accountAddress].accountAddress == address(0), "Admin already exists");

        admins[_accountAddress] = Admin({
            name: _name,
            ID: _ID,
            accountAddress: _accountAddress,
            username: _username,
            status: _status
        });
        
        adminIDs[_ID] = _accountAddress;
        adminCount++;

        return "Admin created successfully";
    }

    function addUser(string memory _name, uint256 _ID, uint8 _userLevel, address _accountAddress, string memory _username, Status _status) public onlyAdmin returns (string memory){
        require(users[_accountAddress].accountAddress == address(0), "User already exists");
        require(_userLevel == 1 || _userLevel == 2, "Invalid user level");

        users[_accountAddress] = User({
            name: _name,
            ID: _ID,
            userLevel: _userLevel,
            accountAddress: _accountAddress,
            username: _username,
            status: _status
        });
        
        userIDs[_ID] = _accountAddress;
        userCount++;

        return "User created successfully";
    }

    function getAdminByID(uint256 _ID) public view onlySuperAdmin returns (Admin memory) {
        address adminAddress = adminIDs[_ID];
        require(adminAddress != address(0), "Admin not found");
        return admins[adminAddress];
    }

    function getUserByID(uint256 _ID) public view returns (User memory) {
        address userAddress = userIDs[_ID];
        require(userAddress != address(0), "User not found");

        if (msg.sender == superAdminAddress || admins[msg.sender].status == Status.Active) {
            return users[userAddress];
        } else {
            revert("Not authorized to view user data");
        }
    }

    function updateAdmin(string memory _name, uint256 _ID, address _accountAddress, string memory _username, Status _status) public onlySuperAdmin {
        require(admins[_accountAddress].accountAddress != address(0), "Admin does not exist");

        admins[_accountAddress].name = _name;
        admins[_accountAddress].ID = _ID;
        admins[_accountAddress].username = _username;
        admins[_accountAddress].status = _status;
    }

    function updateUser(uint256 _ID, string memory _name, uint8 _userLevel, address _accountAddress, string memory _username, Status _status) public onlyAdmin {
        require(users[_accountAddress].accountAddress != address(0), "User does not exist");

        users[_accountAddress].ID = _ID;
        users[_accountAddress].name = _name;
        users[_accountAddress].userLevel = _userLevel;
        users[_accountAddress].username = _username;
        users[_accountAddress].status = _status;
    }

    function getAllAdmins() public view onlySuperAdmin returns (Admin[] memory) {
        Admin[] memory adminsArray = new Admin[](adminCount);
        uint256 index = 0;
        for (uint256 i = 1; i <= adminCount; i++) {
            if (adminIDs[i] != address(0)) {
                adminsArray[index] = admins[adminIDs[i]];
                index++;
            }
        }
        return adminsArray;
    }

    function getAllUsers() public view returns (User[] memory) {
        require(msg.sender == superAdminAddress || admins[msg.sender].status == Status.Active, "Not authorized to view all users data");

        User[] memory usersArray = new User[](userCount);
        uint256 index = 0;
        for (uint256 i = 1; i <= userCount; i++) {
            if (userIDs[i] != address(0)) {
                usersArray[index] = users[userIDs[i]];
                index++;
            }
        }
        return usersArray;
    }

    function addCase(string memory _caseTitle, uint256 _caseID, string memory _caseType, uint8 _caseLevel, string memory _reportHash) public onlyLevelOne returns (string memory){
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

        return "Case added successfully";
    }

    function addEvidence(uint256 _caseID, string memory _evidenceType, string memory _evidenceHash) public onlyLevelTwo returns (string memory){
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

    function getEvidenceByCaseID(uint256 _caseID) public view returns (Evidence[] memory) {
        require(cases[_caseID].caseID != 0, "Case does not exist");
        return caseEvidence[_caseID];
    }

    function getEvidenceByType(uint256 _caseID, string memory _evidenceType) public view returns (Evidence[] memory) {
        require(cases[_caseID].caseID != 0, "Case does not exist");

        uint256 count = 0;
        for (uint256 i = 0; i < caseEvidence[_caseID].length; i++) {
            if (keccak256(abi.encodePacked(caseEvidence[_caseID][i].evidenceType)) == keccak256(abi.encodePacked(_evidenceType))) {
                count++;
            }
        }

        Evidence[] memory filteredEvidence = new Evidence[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < caseEvidence[_caseID].length; i++) {
            if (keccak256(abi.encodePacked(caseEvidence[_caseID][i].evidenceType)) == keccak256(abi.encodePacked(_evidenceType))) {
                filteredEvidence[index] = caseEvidence[_caseID][i];
                index++;
            }
        }

        return filteredEvidence;
    }
}
