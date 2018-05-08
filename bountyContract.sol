pragma solidity ^0.4.23;

contract BountyBG {

    struct Bounty {
        uint256 id;
        address owner;
        uint256 bounty;
        uint256 remainingBounty;
        uint256 startTime;
        uint256 endTime;
        bool ended;
        bool retracted;
    }

    address public owner;
    uint256 public minBountyAmount = 10 finney;
    uint256 public bountyFee = 2 finney;
    uint256 public totalFeeCollected = 0;
    uint256 public bountyBeneficiariesCount = 2;
    uint256 public bountyDuration = 30 hours;

    Bounty[] public bounties;
    mapping(uint => address) public bountyOwner;
    mapping(address => uint[]) ownedBounties;

    event BountyStatus(string _msg, uint256 _id, address _from, uint256 _amount);
    event RewardStatus(string _msg, uint256 _id, address _to, uint256 _amount);
    event ErrorStatus(string _msg, uint256 _id, address _to, uint256 _amount);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    // ========================
    // OWNER ONLY ACTIONS
    // ========================
    function withdrawFee(uint256 _amount) external onlyOwner {
        require(_amount <= totalFeeCollected);
        totalFeeCollected -= _amount;
        owner.transfer(_amount);
    }

    function setBountyDuration(uint256 _bountyDuration) external onlyOwner {
        bountyDuration = _bountyDuration;
    }

    function setMinBountyAmount(uint256 _minBountyAmount) external onlyOwner {
        minBountyAmount = _minBountyAmount;
    }

    function setBountyBeneficiariesCount(uint256 _bountyBeneficiariesCount) external onlyOwner {
        bountyBeneficiariesCount = _bountyBeneficiariesCount;
    }

    function destroyContract() external onlyOwner {
        selfdestruct(owner);
    }

    function rewardUsers(uint256 _bountyId, address[] _users, uint256[] _rewards) external onlyOwner {
        Bounty storage bounty = bounties[_bountyId];
        require(
            !bounty.ended &&
            !bounty.retracted &&
            bounty.startTime + bountyDuration > block.timestamp &&
            _users.length > 0 &&
            _users.length <= bountyBeneficiariesCount &&
            _users.length == _rewards.length
        );

        bounty.ended = true;
        bounty.endTime = block.timestamp;
        uint256 currentRewards = 0;
        for (uint8 i = 0; i < _rewards.length; i++) {
            currentRewards += _rewards[i];
        }

        require(bounty.bounty >= currentRewards);
        bounty.remainingBounty -= currentRewards;

        for (i = 0; i < _users.length; i++) {
            _users[i].transfer(_rewards[i]); // TODO: use withdraw pattern
            emit RewardStatus("Reward sent", bounty.id, _users[i], _rewards[i]);
        }
    }

    function rewardUser(uint256 _bountyId, address _user, uint256 _reward) external onlyOwner {
        Bounty storage bounty = bounties[_bountyId];
        require(bounty.remainingBounty >= _reward);
        bounty.remainingBounty -= _reward;

        bounty.ended = true;
        bounty.endTime = block.timestamp;

        _user.transfer(_reward); // TODO: use withdraw pattern
        emit RewardStatus('Reward sent', bounty.id, _user, _reward);
    }

    // ========================
    // USER ACTIONS
    // ========================
    function createBounty() external payable {
        require(msg.value >= minBountyAmount + bountyFee);

        uint id = bounties.length;
        uint bountyAmount = msg.value - bountyFee;
        totalFeeCollected += bountyFee;

        ownedBounties[msg.sender].push(id);
        bountyOwner[id] = msg.sender;

        bounties.push(Bounty(id, msg.sender, bountyAmount, bountyAmount, block.timestamp, 0, false, false));
        emit BountyStatus('Bounty submitted', id, msg.sender, bountyAmount);
    }

    function cancelBounty(uint256 _bountyId) external {
        Bounty storage bounty = bounties[_bountyId];
        require(
            msg.sender == bounty.owner &&
            !bounty.ended &&
            !bounty.retracted &&
            bounty.startTime + bountyDuration < block.timestamp
        );
        bounty.ended = true;
        bounty.retracted = true;
        bounty.owner.transfer(bounty.bounty); //TODO: use withdraw pattern!! Potential re-entrance attack!
        emit BountyStatus('Bounty was canceled', bounty.id, msg.sender, bounty.bounty);
    }


    // ========================
    // CUSTOM GETTERS
    // ========================
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getTotalBounties() external view returns (uint256) {
        return bounties.length;
    }

    function getOwnersBounties(address _owner) external view returns (uint[]) {
        return ownedBounties[_owner];
    }


}
