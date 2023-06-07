// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./GuildToken.sol";
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
contract ValidatorSelection is ReentrancyGuard{
    struct Validator {
        address validatorAddress;
        uint256 stakingBalance;
    }

    mapping(address => Validator) public validators;
    address[] public validatorQueue; // Priority queue to hold validator addresses
    address public guild_token_address;

    constructor (address _guild_token_address){
        require(_guild_token_address != address(0), "Zero address detected");
        guild_token_address = _guild_token_address;
    }

    // Function to add a validator
    function addValidator(address _validatorAddress, uint256 _stakingBalance) external nonReentrant{
        require(validators[_validatorAddress].validatorAddress == address(0), "Validator already exists");
        require(_stakingBalance > 0 , "staking balance has to be above 0");
        TransferHelper.safeTransferFrom(
            guild_token_address,_validatorAddress,address(this), _stakingBalance
        );
        validators[_validatorAddress] = Validator(_validatorAddress, _stakingBalance);
        insertIntoQueue(_validatorAddress);
    }

    // Function to update the staking balance of a validator
    // Needs approval incase the new staking balance is smaller than the old one
    function updateStakingBalance(address _validatorAddress, uint256 _newStakingBalance) external nonReentrant{
        require(validators[_validatorAddress].validatorAddress != address(0), "Validator does not exist");
        require(_newStakingBalance > 0, "staking balance has to be above 0");
        uint _stakingBalance = validators[_validatorAddress].stakingBalance;
        if(_newStakingBalance < _stakingBalance){
             TransferHelper.safeTransfer(guild_token_address, _validatorAddress, (_stakingBalance-_newStakingBalance));
        }
        else if(_newStakingBalance > _stakingBalance){
            TransferHelper.safeTransferFrom(
            guild_token_address,_validatorAddress,address(this), (_stakingBalance-_newStakingBalance)
        );
        }
        removeValidatorFromQueue(_validatorAddress);
        validators[_validatorAddress].stakingBalance = _newStakingBalance;
        insertIntoQueue(_validatorAddress);
    }

    // Function to remove a validator
    function removeValidator(address _validatorAddress) external nonReentrant{
        require(validators[_validatorAddress].validatorAddress != address(0), "Validator does not exist");
        TransferHelper.safeTransfer(guild_token_address, _validatorAddress, validators[_validatorAddress].stakingBalance);
        removeValidatorFromQueue(_validatorAddress);
        delete validators[_validatorAddress];
    }

    // Function to get the validator with the highest staking balance
    function getTopValidator() external view returns (address) {
        require(validatorQueue.length > 0, "No validators exist");
        
        return validatorQueue[0];
    }

    // Internal function to insert a validator into the priority queue
    function insertIntoQueue(address _validatorAddress) internal {
        uint256 length = validatorQueue.length;
        uint256 stakingBalance = validators[_validatorAddress].stakingBalance;
        uint256 i = length;
        
        while (i > 0 && validators[validatorQueue[i - 1]].stakingBalance < stakingBalance) {
            validatorQueue[i] = validatorQueue[i - 1];
            i--;
        }
        
        validatorQueue[i] = _validatorAddress;
        validatorQueue.push(); // Increase the length of the array by 1
    }

    // Internal function to remove a validator from the priority queue
    function removeValidatorFromQueue(address _validatorAddress) internal {
        uint256 length = validatorQueue.length;
        uint256 i = 0;
        
        while (i < length && validatorQueue[i] != _validatorAddress) {
            i++;
        }
        
        require(i < length, "Validator not found in the queue");
        
        for (; i < length - 1; i++) {
            validatorQueue[i] = validatorQueue[i + 1];
        }
        
        validatorQueue.pop(); // Remove the last element from the array
    }

}
