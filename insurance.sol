// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract InsuranceContract is ERC20, Ownable {
    address public insuranceAddress = 0xd7b5B1e52369F1402Ba350d7f5Dd3D247717c157;
    uint public registeredInsurance;
    uint public registeredCustomer;
    uint256 oneYearInSeconds = 31536000; // 1 year in seconds

    constructor() ERC20("Bader Insurance", "BDR") {}

    mapping(address => User) public users;

    struct User {
        string userName;
        address userAddress;
        uint userAge;
        uint userBalance;
        uint startInsurance;
        uint endInsurance;
        
    }

    

    // Check if a customer has insurance and has allowance
    function hasInsuranceAndAllowance(uint allowanceneeded,address customer) private view returns (bool) {
    // Check if the customer has insurance
        if (users[customer].startInsurance != 0) {
        // Check if the customer has an allowance (balance > allowanceneeded)
        return balanceOf(customer) >= allowanceneeded;
    } else {
        // Customer does not have insurance
        return false;
    }
}

// Compensation function that allows withdrawal
    function compensation(uint money) public {
        address customer = msg.sender;

        // Check if the customer has insurance and allowance
        require(hasInsuranceAndAllowance(money,customer),"Customer does not meet criteria");

        // Perform compensation logic here
        // For example, transfer tokens to the customer
        uint amountToTransfer = money; // Replace with your compensation amount
        _transfer(insuranceAddress, customer, amountToTransfer);

        // Update any other necessary state variables or logic
    }
    
    function registerCustomer(string memory newName, uint newAge) public payable {
        require(
            newAge <= 18,
            "You are under the age"
        );
        require(
            balanceOf(msg.sender) == 0,
            "Money is required"
        );
        
        uint newBalance = balanceOf(msg.sender);
        _transfer(msg.sender, insuranceAddress, 0);
        
        users[msg.sender] = User(
            newName,
            msg.sender,
            newAge,
            newBalance,
            block.timestamp, // Initialize startInsurance with the current timestamp
            0
        );
        
        registeredCustomer++;
    }
    // Add this function to your existing contract

// Function to allow a registered user to buy insurance
    function buyInsurance() public {
        address customer = msg.sender;

        // Check if the customer is registered
        require(users[customer].startInsurance == 0, "You are not a registered user");


        // Perform insurance purchase logic here
        // For example, deduct tokens from the customer and set the insurance period
        uint insuranceCost = 1 ether; // Replace with the actual cost of insurance

        // Check if the customer has enough balance to purchase insurance
        require(balanceOf(customer) >= insuranceCost, "Insufficient balance to buy insurance");

        // Deduct the insurance cost from the customer's balance
        _transfer(customer, insuranceAddress, insuranceCost);

        // Set the start and end dates of the insurance coverage
        uint startTimestamp = block.timestamp;
        uint endTimestamp = startTimestamp + oneYearInSeconds;
        
        users[customer].startInsurance = startTimestamp;
        users[customer].endInsurance = endTimestamp;

        registeredInsurance++;
    }


}
