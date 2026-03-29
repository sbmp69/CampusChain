// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Interfaces to fetch reputation multiplier from Identity Contract
interface ICampusIdentity {
    function getReputation(address student) external view returns (uint256);
}

/**
 * @title CampusToken
 * @dev An ERC-1155 tracking Academic, Utility, and Impact tokens. Applies reputation-based multipliers when minting.
 */
contract CampusToken is ERC1155, Ownable {

    uint256 public constant ACADEMIC_TOKEN = 0;
    uint256 public constant UTILITY_TOKEN = 1;
    uint256 public constant IMPACT_TOKEN = 2;

    ICampusIdentity public identityContract;

    event TokensEarned(address indexed student, uint256 tokenId, uint256 baseAmount, uint256 finalAmount, uint256 multiplierBase10);
    event TokensSpent(address indexed student, uint256 tokenId, uint256 amount);

    // authorized distributors (e.g. cafeteria POS, LMS system)
    mapping(address => bool) public authorizedDistributors;

    constructor(address _identityContractAddr) ERC1155("https://campuschain.local/api/token/{id}.json") Ownable(msg.sender) {
        identityContract = ICampusIdentity(_identityContractAddr);
    }

    modifier onlyAuthorized() {
        require(owner() == msg.sender || authorizedDistributors[msg.sender], "Not authorized distributor");
        _;
    }

    /**
     * @dev Add a smart contract or system capable of distributing these tokens autonomously.
     */
    function setDistributor(address distributor, bool status) external onlyOwner {
        authorizedDistributors[distributor] = status;
    }

    /**
     * @dev Sets a new identity contract address if it is upgraded
     */
    function setIdentityContract(address newAddress) external onlyOwner {
        identityContract = ICampusIdentity(newAddress);
    }

    /**
     * @dev Earn tokens with reputation-based multipliers.
     * Example: 90 reputation = 1.3x multiplier (returns +30% more tokens).
     */
    function earnTokens(address student, uint256 tokenId, uint256 baseAmount) external onlyAuthorized {
        uint256 reputation = identityContract.getReputation(student);
        uint256 multiplierBase10 = 10; // Default 1.0x

        // High reputation boosts token earnings
        if (reputation >= 90) {
            multiplierBase10 = 15; // 1.5x
        } else if (reputation >= 80) {
            multiplierBase10 = 13; // 1.3x
        } else if (reputation <= 30) {
            multiplierBase10 = 8; // 0.8x (penalty)
        }

        uint256 finalAmount = (baseAmount * multiplierBase10) / 10;

        _mint(student, tokenId, finalAmount, "");
        emit TokensEarned(student, tokenId, baseAmount, finalAmount, multiplierBase10);
    }

    /**
     * @dev Spend tokens (burning the amount from the student's supply)
     */
    function spendTokens(address student, uint256 tokenId, uint256 amount) external onlyAuthorized {
        require(balanceOf(student, tokenId) >= amount, "Insufficient token balance");
        
        _burn(student, tokenId, amount);
        emit TokensSpent(student, tokenId, amount);
    }
}
