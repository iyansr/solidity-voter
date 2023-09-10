// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract VoterProject {
    struct Voter {
        uint weight;
        bool voted;
        uint votedProposal;
        address delegate;
    }

    struct Proposal {
        string name;
        uint voteCount;
    }

    address public chairman;
    Proposal[] public proposals;

    mapping(address => Voter) public voters;

    constructor(string[] memory proposalNames) {
        chairman = msg.sender;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }
    }

    function vote(uint proposalIndex) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        require(sender.weight != 0, "Has no right to vote.");

        sender.voted = true;
        sender.votedProposal = proposalIndex;

        proposals[proposalIndex].voteCount += sender.weight;
    }

    function abilityToVote(address voter) public {
        require(
            msg.sender == chairman,
            "Only chairman can give right to vote."
        );
        require(!voters[voter].voted, "The voter already voted.");
        require(
            voters[voter].weight == 0,
            "The voter already has right to vote."
        );

        voters[voter].weight = 1;
    }

    function winningProposal() public view returns (uint winningProposal_) {
        uint winningVoteCount = 0;

        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposal_ = i;
            }
        }
    }

    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            require(to != msg.sender, "Found loop in delegation.");
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage _delegate = voters[to];

        if (_delegate.voted) {
            proposals[_delegate.votedProposal].voteCount += sender.weight;
        } else {
            _delegate.weight += sender.weight;
        }
    }

    function winnerProposal() public view returns (string memory winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }
}
