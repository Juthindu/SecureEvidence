// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureEvidence {
    address superAdminAddress = 0xaE66570C9252Ad7c82A76371Dce460129538d7D7;
    string superAdminUsername = "SuperAdmin";

    enum Status {Inactive, Active}
    enum UserRole {LevelTwo, LevelOne, Admin}
    event SuperAdminChanged(address oldSuperAdmin, string oldSuperAdminUsername, address newSuperAdmin, string newSuperAdminUsername);
    event GuidelineHashUpdated(string newGuidelineHash, address updatedBy);
    
    struct Account {
        string name;
        string ID;
        address accountAddress;
        string username;
        Status status;
        UserRole role;
    }

    struct Type {
        string caseTypeID;
        string description;
        string category;
        uint8 level;
    }

    struct Case {
        string caseTitle;
        string caseID;
        string caseTypeID;
        string reportHash;
        address addedBy;
        Status status;
    }

    struct Evidence {
        string caseID;
        string evidenceID;
        string evidenceType;
        string evidenceHash;
        address addedBy;
        Status status;
    }

    mapping(address => Account) accounts;
    mapping(string => address) accountIDs;
    mapping(string => bool) caseType;
    mapping(string => Case) cases;
    mapping(string => Type) typesByID;
    mapping(string => Case[]) casesByType;
    mapping(string => Evidence[]) caseEvidence;
    mapping(string => Evidence) evidenceByID;
    mapping(string => uint256) public evidenceIndexByID;
    
    uint256 accountCount;
    uint256 public evidenceCount;
    uint256 public caseCount;
    uint256 public typeCount;
    string public guidelineHash; 

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
    
    function addressToIndex(string memory _id) private view returns (address) {
        return accountIDs[_id];
    }
}
