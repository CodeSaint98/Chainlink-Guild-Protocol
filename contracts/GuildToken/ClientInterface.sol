// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./GuildToken.sol";
import "./ValidatorSelection.sol";
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

contract ClientInterface{
    address public guild_token_address;
    address public validator_selection_address;
    struct ProposalDetails {
        address client_address;
        address freelancer_address;
        address validator;
        uint256 bountyAmount;
    }
    mapping(address => ProposalDetails) public proposalDetails;

    function createProposal(address _client_address,uint _bountyAmount) public {
        require(_client_address != address(0) && _bountyAmount !=0, "Zero values detected");
        TransferHelper.safeTransferFrom(
            guild_token_address,msg.sender, address(this), _bountyAmount
        );
        proposalDetails[_client_address].client_address = _client_address;
        proposalDetails[_client_address].bountyAmount = _bountyAmount;
        proposalDetails[_client_address].validator = ValidatorSelection(validator_selection_address).getTopValidator();
    }
}