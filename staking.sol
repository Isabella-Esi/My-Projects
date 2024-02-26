pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// Importing the ERC20 token from OpenZeppelin

contract MyToken is ERC20 {
    // Creating a contract MyToken inheriting from the ERC20 contract

    mapping(address => uint) public staked;
    mapping(address => uint) private stakedFromTS;
    // Mappings that track the amount staked by each address and the timestamp of their stakes
                                            
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 1000);
        /* Constructor to initialize MyToken with a supply of 1000 units, 
        minted to the contract deployer*/
    }

    function stake(uint amount) external {
        // Function for staking coins
        require(amount > 0, "Amount must be greater than 0");
        // The amount staked has to be greater than 0

        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        // The balance of the sender has to be greater than or equal to the amount being staked

        _transfer(msg.sender, address(this), amount);
        // Transfer funds from the sender to this contract

        if (staked[msg.sender] > 0) {
            claim();
            // If the sender had previously staked, they can claim their rewards
        }

        stakedFromTS[msg.sender] = block.timestamp;
        // Save the current timestamp to record when the user stakes
        staked[msg.sender] += amount;
        // Add the amount staked by the sender
    }

    function unstake(uint amount) external {
        // Function to unstake
        require(amount > 0, "Amount must be greater than 0");
        // Amount staked has to be more than 0

        require(staked[msg.sender] > 0, "No staked amount to unstake");
        // The user must have previously staked some amount to use this function

        stakedFromTS[msg.sender] = block.timestamp;
        // Record the current timestamp in the mapping

        staked[msg.sender] -= amount;
        // Subtract the unstaked funds from the user's staked amount

        _transfer(address(this), msg.sender, amount);
        // Transfer the unstaked amount back to the user
    }

    function claim() public {
        // Function to claim rewards
        require(staked[msg.sender] > 0, "No staked amount to claim rewards");
        // The user must have staked some funds

        uint secondsStaked = block.timestamp - stakedFromTS[msg.sender];
        uint rewards = staked[msg.sender] * secondsStaked / 3.154e7; 
        // Calculate rewards based on the amount staked and the duration

        _mint(msg.sender, rewards);
        // Mint the calculated rewards to the user
        stakedFromTS[msg.sender] = block.timestamp;
        // Update the timestamp of the user's last claim
    }
}

 