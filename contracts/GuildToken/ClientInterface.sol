// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./GuildToken.sol";
import "./ValidatorSelection.sol";
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract ClientInterface is ReentrancyGuard{
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
    //keeps track of how much guild token is owed to addresses
    mapping(address => uint) redeemBalances;

    constructor(address _guild_token_address, address _validator_selection_address){
        require((_guild_token_address != address(0))
        &&(_validator_selection_address != address(0)), "Zero address detected");
        guild_token_address = _guild_token_address;
        validator_selection_address = _validator_selection_address;
    }

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
    function confirmProposal(address _freelancer_address,uint _bountyAmount, uint _proposal_hash) public nonReentrant{
        require(_freelancer_address != address(0), "Zero values detected");
        require(msg.sender == proposalDetails[proposal_hash].client_address || msg.sender == proposalDetails[proposal_hash].validator, "Not Authorized");
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
    function confirmPayment(uint _proposal_hash) public nonReentrant{
        uint thirdparty_bounty = (25*proposalDetails[_proposal_hash].bountyAmount)/1000;
        proposalDetails[_proposal_hash].bountyAmount = proposalDetails[_proposal_hash].bountyAmount - thirdparty_bounty;
        redeemBalances[proposalDetails[_proposal_hash].validator] += thirdparty_bounty;
        redeemBalances[proposalDetails[_proposal_hash].freelancer_address] += proposalDetails[_proposal_hash].bountyAmount;
        proposalDetails[_proposal_hash].bountyAmount = 0;
    }

    function releasePayment() public nonReentrant{
        for(uint i=0; i<proposal_hash+1;i++){
            if(redeemBalances[proposalDetails[proposal_hash].freelancer_address] != 0){
                TransferHelper.safeTransfer(guild_token_address, proposalDetails[proposal_hash].freelancer_address, redeemBalances[proposalDetails[proposal_hash].freelancer_address]);
            }
            if(redeemBalances[proposalDetails[proposal_hash].validator] != 0){
                TransferHelper.safeTransfer(guild_token_address, proposalDetails[proposal_hash].validator, redeemBalances[proposalDetails[proposal_hash].validator]);
            }
        }
    }
}