// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CampusIdentity
 * @dev Tracks student accounts, their academic details, and dynamic reputation scores.
 */
contract CampusIdentity is Ownable {
    
    struct Student {
        string studentId;       // e.g., "STU-2026-001"
        string name;            // e.g., "Meet Patel"
        string department;      // e.g., "Computer Science"
        string year;            // e.g., "3rd Year"
        uint256 reputationScore;// 0 to 100
        bool isRegistered;
    }

    // Mapping from wallet address to Student struct
    mapping(address => Student) public students;
    
    // Reverse mapping for looking up address by ID (simplified)
    mapping(string => address) public idToAddress;

    // Authorized smart contracts that can modify reputation (e.g., Rewards contract)
    mapping(address => bool) public authorizedModifiers;

    event StudentRegistered(address indexed wallet, string studentId, string name);
    event ReputationUpdated(address indexed wallet, uint256 newScore);

    constructor() Ownable(msg.sender) {}

    modifier onlyAuthorized() {
        require(owner() == msg.sender || authorizedModifiers[msg.sender], "Not authorized");
        _;
    }

    /**
     * @dev Register a new student on the blockchain
     */
    function registerStudent(
        address wallet,
        string memory _studentId,
        string memory _name,
        string memory _department,
        string memory _year
    ) external onlyOwner {
        require(!students[wallet].isRegistered, "Wallet already registered");
        require(idToAddress[_studentId] == address(0), "Student ID already exists");

        students[wallet] = Student({
            studentId: _studentId,
            name: _name,
            department: _department,
            year: _year,
            reputationScore: 50, // Starting default reputation
            isRegistered: true
        });

        idToAddress[_studentId] = wallet;

        emit StudentRegistered(wallet, _studentId, _name);
    }

    /**
     * @dev Increase or decrease reputation based on actions (capped at 100)
     */
    function updateReputation(address wallet, int256 change) external onlyAuthorized {
        require(students[wallet].isRegistered, "Student not registered");

        int256 currentScore = int256(students[wallet].reputationScore);
        int256 newScore = currentScore + change;

        if (newScore > 100) newScore = 100;
        if (newScore < 0) newScore = 0;

        students[wallet].reputationScore = uint256(newScore);
        emit ReputationUpdated(wallet, uint256(newScore));
    }

    function addAuthorizedModifier(address modifierContract) external onlyOwner {
        authorizedModifiers[modifierContract] = true;
    }

    /**
     * @dev Helper to quickly fetch reputation for DAO & Token contracts
     */
    function getReputation(address wallet) external view returns (uint256) {
        return students[wallet].reputationScore;
    }
}
