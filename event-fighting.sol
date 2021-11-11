pragma solidity ^0.5.0;

/*
 * @title: SafeMath
 * @dev: Helper contract functions to arithmatic operations safely.
 */
contract SafeMath {
    function Sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function Add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    
    function Divisable(uint256 a, uint256 b) internal pure returns (bool) {
        require(b <= a, "SafeMath: subtraction overflow");
        return (a % b == 0);
    }

    function Mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
}

contract DragonTrainning {
    function trainDragon(uint256 dragonId) external;
}

contract DragonFightBoss {
    function fightMonsterYY(uint256 dragonId, uint256 monsterId) external;
    function fightMonsterXX(uint256 dragonId, uint256 monsterId) external;
}

contract Dragon {
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function transfer(address _to, uint256 _tokenId) external;
}

contract Trainning is SafeMath {
    address constant public TRAINNING_ADDRESS = 0xE5dAA2925C7E6Bc9e6F46aBd6d0c4004C287919f;
    address constant public FIGHTING_ADDRESS = 0x698Da487714c33BC95d74BDeD59d2848Ea3Bc7C2;
    address constant public DRAGON_ADDRESS = 0x7acf2aE0a38AB846c7E46EbA2b419165fd312b8f;
    uint256 public FEE_TRAIN = 1000000000000000000;
    uint256 public FEE_FIGHT = 1000000000000000000;
    address public owner;
    address payable FEE_ADDRESS = 0x8128196748C69994cF016576eC7809292938ae2F;
    mapping(address => uint256) balance;
    mapping(uint256 => address) ownerOf;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function updateFeeTrain(uint256 fee) public onlyOwner {
        FEE_TRAIN = fee;
    }
    
    function updateFeeFight(uint256 fee) public onlyOwner {
        FEE_FIGHT = fee;
    }
    
    function escrowDragon(uint256 dragonId) external payable {
        require(Dragon(DRAGON_ADDRESS).ownerOf(dragonId) == msg.sender);
        require(msg.value > 0);
        Dragon(DRAGON_ADDRESS).transferFrom(msg.sender, address(this), dragonId);
        balance[msg.sender] = Add(balance[msg.sender], msg.value);
        ownerOf[dragonId] = msg.sender;
    }
    
    function trainDragon(uint256 dragonId) external {
        require(balance[ownerOf[dragonId]] > FEE_TRAIN);
        require(FEE_ADDRESS.send(FEE_TRAIN));
        balance[ownerOf[dragonId]] = balance[ownerOf[dragonId]] - FEE_TRAIN;
        DragonTrainning(TRAINNING_ADDRESS).trainDragon(dragonId);
    }
    
    function fightMonsterYY(uint256 dragonId, uint256 monsterId) external {
        require(balance[ownerOf[dragonId]] > FEE_FIGHT);
        require(FEE_ADDRESS.send(FEE_FIGHT));
        balance[ownerOf[dragonId]] = balance[ownerOf[dragonId]] - FEE_FIGHT;
        DragonFightBoss(FIGHTING_ADDRESS).fightMonsterYY(dragonId, monsterId);
    }
    
    function fightMonsterXX(uint256 dragonId, uint256 monsterId) external {
        require(balance[ownerOf[dragonId]] > FEE_FIGHT);
        require(FEE_ADDRESS.send(FEE_FIGHT));
        balance[ownerOf[dragonId]] = balance[ownerOf[dragonId]] - FEE_FIGHT;
        DragonFightBoss(FIGHTING_ADDRESS).fightMonsterXX(dragonId, monsterId);
    }
    
    function withdrawDragon(uint256 dragonId) external {
        require(ownerOf[dragonId] == msg.sender);
        Dragon(DRAGON_ADDRESS).transfer(ownerOf[dragonId], dragonId);
        ownerOf[dragonId] = address(0);
    }
    
    function withdrawBalance() external {
        require(balance[msg.sender] > 0);
        require(msg.sender.send(balance[msg.sender]));
        balance[msg.sender] = 0;
    }
    
    function topUpBalance() external payable {
        require(msg.value > 0);
        balance[msg.sender] = Add(balance[msg.sender], msg.value);
    }
    
    function getOwnerOfDragon(uint256 dragonId) external view returns(address dragonOwner) {
        dragonOwner = ownerOf[dragonId];
    }
    
    function getBalance(address dragonOwner) external view returns(uint256 ownerBalance) {
        ownerBalance = balance[dragonOwner];
    }
    
    function () external payable {}
    
    function emergencyWithdrawalKai(uint256 amount) public onlyOwner {
        require(msg.sender.send(amount));
    }
    
    function emergencyWithdrawalDragon(uint256 dragonId) public onlyOwner {
        Dragon(DRAGON_ADDRESS).transfer(ownerOf[dragonId], dragonId);
        ownerOf[dragonId] = address(0);
    }
}