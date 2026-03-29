// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

// Interfaces to fetch reputation multiplier from Identity Contract
interface ICampusIdentity {
    function getReputation(address student) external view returns (uint256);
}

/**
 * @title CampusDAO
 * @dev Governance voting system where high-reputation students have boosted voting power.
 */
contract CampusDAO is Ownable {

    ICampusIdentity public identityContract;

    event ProposalCreated(uint256 indexed proposalId, string title, string description, address creator);
    event Voted(uint256 indexed proposalId, address voter, bool inFavor, uint256 vp);

    struct Proposal {
        uint256 id;
        string title;
        string description;
        address creator;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 totalVoters;
        bool isActive;
    }

    // Mapping from proposal ID -> Proposal
    mapping(uint256 => Proposal) public proposals;
    uint256 public nextProposalId;

    // Mapping tracking if a wallet has voted on a proposalId
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    constructor(address _identityContractAddr) Ownable(msg.sender) {
        identityContract = ICampusIdentity(_identityContractAddr);
    }

    /**
     * @dev Create a new campus vote proposal
     */
    function createProposal(string memory title, string memory description) external {
        uint256 rep = identityContract.getReputation(msg.sender);
        require(rep >= 50, "Reputation too low to author proposals");

        Proposal storage p = proposals[nextProposalId];
        p.id = nextProposalId;
        p.title = title;
        p.description = description;
        p.creator = msg.sender;
        p.isActive = true;

        emit ProposalCreated(nextProposalId, title, description, msg.sender);
        nextProposalId++;
    }

    /**
     * @dev Cast a vote on an active proposal. High reputation counts as more votes.
     */
    function vote(uint256 proposalId, bool inFavor) external {
        Proposal storage p = proposals[proposalId];
        require(p.isActive, "Proposal is not active");
        require(!hasVoted[proposalId][msg.sender], "Already voted on this proposal");

        uint256 rep = identityContract.getReputation(msg.sender);
        uint256 votingPower = 100; // base VP

        if (rep >= 90) {
            votingPower = 150; // 1.5x power
        } else if (rep >= 80) {
            votingPower = 130; // 1.3x power
        } else if (rep < 30) {
            votingPower = 80;  // 0.8x power
        }

        hasVoted[proposalId][msg.sender] = true;
        p.totalVoters += 1;

        if (inFavor) {
            p.votesFor += votingPower;
        } else {
            p.votesAgainst += votingPower;
        }

        emit Voted(proposalId, msg.sender, inFavor, votingPower);
    }

    /**
     * @dev Conclude the vote
     */
    function closeProposal(uint256 proposalId) external onlyOwner {
        proposals[proposalId].isActive = false;
    }
}
