// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// Interface for ERC20 token
interface IERC20 {
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}

// Crowdfunding contract
contract CrowdFund {
    // Event that happens when a campaign is launched
    event Launch(
        uint id,
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );
    // Event that happens when a campaign is cancelled
    event Cancel(uint id);
    // Event that happens when funds are pledged to a campaign
    event Pledge(uint indexed id, address indexed caller, uint amount);
    // Event that happens when a pledge is cancelled
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    // Event that happens when funds are claimed by the campaign creator
    event Claim(uint id);
    // Event that happens when funds are refunded to a pledger
    event Refund(uint id, address indexed caller, uint amount);

    // Struct representing a crowdfunding campaign literally the structure of the campaign
    struct Campaign {
        address creator;    // Creator of campaign
        uint goal;          // Amount of tokens to raise
        uint pledged;       // Total amount pledged
        uint32 startAt;     // Timestamp of start of campaign
        uint32 endAt;       // Timestamp of end of campaign
        bool claimed;       // True if goal was reached and creator has claimed the tokens
    }

    // Immutable ERC20 token contract address
    IERC20 public immutable token;
    // Total count of campaigns created
    uint public count;
    // This Mapping saves information of each campaign based on its ID

    mapping(uint => Campaign) public campaigns;
    /*This is a nested mapping that saves information on the amount
     pledged by each address for each campaign*/

    mapping(uint => mapping(address => uint)) public pledgedAmount;

    // Constructor to set the ERC20 token contract address
    constructor(address _token) {
        token = IERC20(_token);
    }

    // Function to launch a new campaign
    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        // Require that the start time is in the future
        require(_startAt >= block.timestamp, "start at < now");
        // Require that the end time is after the start time
        require(_endAt >= _startAt, "end at < start at");
        // Require that the end time is within 90 days from now
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");

        // Increment the campaign count
        count += 1;
        // Create a new campaign and store it in the campaigns mapping
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        // Emit a Launch event to note the creation of the campaign to the front end
        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    // Function to cancel a campaign
    function cancel(uint _id) external {
        // Get the campaign from the campaigns mapping
        Campaign memory campaign = campaigns[_id];
        // Require that the sender is the creator of the campaign
        require(campaign.creator == msg.sender, "not creator");
        // Require that the campaign has not yet started
        require(block.timestamp < campaign.startAt, "started");

        // Delete the campaign from the campaigns mapping
        delete campaigns[_id];
        // Emit a Cancel event to note the cancellation of the campaign to the front end
        emit Cancel(_id);
    }

    // Function to pledge funds to a campaign
    function pledge(uint _id, uint _amount) external {
        // Get the campaign from the campaigns mapping
        Campaign storage campaign = campaigns[_id];
        // Require that the campaign has started
        require(block.timestamp >= campaign.startAt, "not started");
        // Require that the campaign has not ended
        require(block.timestamp <= campaign.endAt, "ended");

        // Update the total amount pledged for the campaign
        campaign.pledged += _amount;
        // Update the amount pledged by the caller for the campaign
        pledgedAmount[_id][msg.sender] += _amount;
        // Transfer tokens from the caller to the contract
        token.transferFrom(msg.sender, address(this), _amount);

        // Emit a Pledge event to note the pledge to the front end
        emit Pledge(_id, msg.sender, _amount);
    }

    // Function to unpledge funds from a campaign
    function unpledge(uint _id, uint _amount) external {
        // Get the campaign from the campaigns mapping
        Campaign storage campaign = campaigns[_id];
        // Require that the campaign has not ended
        require(block.timestamp <= campaign.endAt, "ended");

        // Update the total amount pledged for the campaign
        campaign.pledged -= _amount;
        // Update the amount pledged by the caller for the campaign
        pledgedAmount[_id][msg.sender] -= _amount;
        // Transfer tokens from the contract to the caller
        token.transfer(msg.sender, _amount);

        // Emit an Unpledge event to log the unpledge
        emit Unpledge(_id, msg.sender, _amount);
    }

    // Function to claim funds from a campaign
    function claim(uint _id) external {
       // Get the the campaign from the campaigns mapping
        Campaign storage campaign = campaigns[_id];
        // Require that the sender is the creator of the campaign
        require(campaign.creator == msg.sender, "not creator");
        // Require that the campaign has ended
        require(block.timestamp > campaign.endAt, "not ended");
        // Require that the total amount pledged is greater than or equal to the goal
        require(campaign.pledged >= campaign.goal, "pledged < goal");
        // Require that the tokens have not already been claimed
        require(!campaign.claimed, "claimed");

        // Mark the tokens as claimed
        campaign.claimed = true;
        // Transfer tokens from the contract to the creator
        token.transfer(campaign.creator, campaign.pledged);

        // Emit a Claim event to log the claim
        emit Claim(_id);
    }

    // Function to refund funds from a campaign
    function refund(uint _id) external {
       // Get the the campaign from the campaigns mapping
        Campaign memory campaign = campaigns[_id];
        // Require that the campaign has ended
        require(block.timestamp > campaign.endAt, "not ended");
        // Require that the total amount pledged is less than the goal
        require(campaign.pledged < campaign.goal, "pledged >= goal");

        // Get the amount pledged by the caller for the campaign
        uint bal = pledgedAmount[_id][msg.sender];
        // Reset the amount pledged by the caller for the campaign
        pledgedAmount[_id][msg.sender] = 0;
        // Transfer tokens from the contract to the caller
        token.transfer(msg.sender, bal);

        // Emit a Refund event to log the refund
        emit Refund(_id, msg.sender, bal);
    }
}


