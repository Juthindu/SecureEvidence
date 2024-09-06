// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SecureEvidence.sol";

contract User is SecureEvidence {

    function addUser(
        string memory _name,
        string memory _ID,
        address _accountAddress,
        string memory _username,
        Status _status,
        UserRole _role
    ) public onlyAdmin returns (string memory) {
        require(accountIDs[_ID] == address(0), "User with this ID already exists");
        require(accounts[_accountAddress].accountAddress == address(0), "User with this address already exists");

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

        return "User added";
    }

    function updateUser(
        string memory _ID,
        string memory _name,
        address _accountAddress,
        string memory _username,
        Status _status,
        UserRole _role
    ) public onlyAdmin returns (string memory) {
        require(accounts[_accountAddress].accountAddress != address(0), "User does not exist");

        accounts[_accountAddress].name = _name;
        accounts[_accountAddress].ID = _ID;
        accounts[_accountAddress].username = _username;
        accounts[_accountAddress].status = _status;
        accounts[_accountAddress].role = _role;

        return "User updated";
    }

    function getUserByID(string memory _ID) public view returns (
    string memory name,
    string memory ID,
    address accountAddress,
    string memory username,
    Status status,
    UserRole role
) {
    address userAddress = accountIDs[_ID];
    require(userAddress != address(0), "User not found");

    Account memory user = accounts[userAddress];
    require(
        user.status == Status.Active &&
        (user.role == UserRole.Admin || user.role == UserRole.LevelOne || user.role == UserRole.LevelTwo) ||
        msg.sender == superAdminAddress, 
        "Unauthorized access"
    );

    return (user.name, user.ID, user.accountAddress, user.username, user.status, user.role);
}
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


}
