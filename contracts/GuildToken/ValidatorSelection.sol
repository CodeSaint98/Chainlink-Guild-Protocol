// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ValidatorSelection {
    struct Validator {
        address validatorAddress;
        uint256 stakingBalance;
    }

    mapping(address => Validator) public validators;
    address[] public validatorQueue; // Priority queue to hold validator addresses

    // Function to add a validator
    function addValidator(address _validatorAddress, uint256 _stakingBalance) external {
        require(validators[_validatorAddress].validatorAddress == address(0), "Validator already exists");
        
        validators[_validatorAddress] = Validator(_validatorAddress, _stakingBalance);
        insertIntoQueue(_validatorAddress);
    }

    // Function to update the staking balance of a validator
    function updateStakingBalance(address _validatorAddress, uint256 _newStakingBalance) external {
        require(validators[_validatorAddress].validatorAddress != address(0), "Validator does not exist");
        
        removeValidatorFromQueue(_validatorAddress);
        validators[_validatorAddress].stakingBalance = _newStakingBalance;
        insertIntoQueue(_validatorAddress);
    }

    // Function to remove a validator
    function removeValidator(address _validatorAddress) external {
        require(validators[_validatorAddress].validatorAddress != address(0), "Validator does not exist");
        
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
