// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./GuildToken.sol";
import "./ValidatorSelection.sol";
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

contract ClientInterface{
    address public guild_token_address;
    address public validator_selection_address;
    uint256 public proposal_hash;
    struct ProposalDetails {
        address client_address;
        address freelancer_address;
        address validator;
        uint256 proposal_hash;
        uint256 bountyAmount;
        bool milestone;
    }
    mapping(uint => ProposalDetails) public proposalDetails;

    function createProposal(address _client_address,uint _bountyAmount, bool milestone) public {
        require(_client_address != address(0) && _bountyAmount !=0, "Zero values detected");
        proposal_hash = proposal_hash + 1;
        proposalDetails[proposal_hash].client_address = _client_address;
        proposalDetails[proposal_hash].milestone = milestone;
        proposalDetails[proposal_hash].bountyAmount = _bountyAmount;
        proposalDetails[proposal_hash].validator = ValidatorSelection(validator_selection_address).getTopValidator();
        proposalDetails[proposal_hash].proposal_hash = proposal_hash;
    }
//check if you can make changing the bounty amount optional
//modifier to check if msg.sender is validator or client of proposal
    function confirmProposal(address _freelancer_address,uint _bountyAmount, uint _proposal_hash) public {
        require(_freelancer_address != address(0), "Zero values detected");
        proposalDetails[_proposal_hash].bountyAmount = _bountyAmount;
        TransferHelper.safeTransferFrom(
            guild_token_address,msg.sender, address(this), _bountyAmount
        );
        proposalDetails[_proposal_hash].freelancer_address = _freelancer_address;
    }
//for milestone based payment
//ability to add more milestones
//should function for all kinds of payments: hourly, milestone and one-time payments
//one-time are milestone payments with only one active payment
//have to take out third party payments from the bounty
//this will be implemented in future versions for now we use automation to release payment on the 1st of every month
    function releasePayment(uint _proposal_hash) public {
        uint thirdparty_bounty = (25*proposalDetails[_proposal_hash].bountyAmount)/1000;
        proposalDetails[_proposal_hash].bountyAmount = proposalDetails[_proposal_hash].bountyAmount - thirdparty_bounty;
        TransferHelper.safeTransfer(guild_token_address,proposalDetails[_proposal_hash].validator, thirdparty_bounty);
        TransferHelper.safeTransfer(guild_token_address,proposalDetails[_proposal_hash].freelancer_address, proposalDetails[_proposal_hash].bountyAmount);
        proposalDetails[_proposal_hash].bountyAmount = 0;
    }
}