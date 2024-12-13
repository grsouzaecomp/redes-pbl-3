// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract DescentralizedBet {
    address public owner;

    struct Bet {
        address bettor;
        uint256 amount;
        uint8 prediction; // 1 or 2
    }

    struct Event {
        string name;
        uint256 odds; // Odds in percentage (e.g., 200 = 2.00 odds)
        uint256 totalAmount;
        bool resolved;
        uint8 result; // 1 or 2
    }

    mapping(uint256 => Event) public bettingEvents;
    mapping(uint256 => Bet[]) public eventBets;
    mapping(address => uint256) public balances;

    uint256 public eventCount;

    event EventCreated(uint256 indexed eventId, string name, uint256 odds);
    event BetPlaced(address indexed bettor, uint256 indexed eventId, uint256 amount, uint8 prediction);
    event EventResolved(uint256 indexed eventId, uint8 result);
    event Payout(address indexed bettor, uint256 payout);
    event WithdrawalAttempt(address indexed user, uint256 amount);
    event ContractBalance(uint256 balance);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createEvent(string memory _name, uint256 _odds) public onlyOwner {
        require(_odds > 0, "Odds must be greater than zero.");
        
        eventCount++;
        bettingEvents[eventCount] = Event({
            name: _name,
            odds: _odds,
            totalAmount: 0,
            resolved: false,
            result: 0
        });

        emit EventCreated(eventCount, _name, _odds);
    }

    function placeBet(uint256 eventId, uint8 prediction) public payable {
        require(eventId > 0 && eventId <= eventCount, "Event does not exist.");
        require(!bettingEvents[eventId].resolved, "Event already resolved.");
        require(prediction == 1 || prediction == 2, "Invalid prediction.");
        require(msg.value > 0, "Bet amount must be greater than zero.");

        eventBets[eventId].push(Bet({
            bettor: msg.sender,
            amount: msg.value,
            prediction: prediction
        }));

        bettingEvents[eventId].totalAmount += msg.value;
        balances[msg.sender] += msg.value;

        emit BetPlaced(msg.sender, eventId, msg.value, prediction);
    }

    function resolveEvent(uint256 eventId, uint8 result) public onlyOwner {
        require(eventId > 0 && eventId <= eventCount, "Event does not exist.");
        require(!bettingEvents[eventId].resolved, "Event already resolved.");
        require(result == 1 || result == 2, "Invalid result.");

        bettingEvents[eventId].resolved = true;
        bettingEvents[eventId].result = result;

        emit EventResolved(eventId, result);

        uint256 totalPayout;
        for (uint256 i = 0; i < eventBets[eventId].length; i++) {
            Bet storage bet = eventBets[eventId][i];
            if (bet.prediction == result) {
                uint256 payout = bet.amount * bettingEvents[eventId].odds / 100;
                balances[bet.bettor] += payout;
                totalPayout += payout;
                emit Payout(bet.bettor, payout);
            }
        }
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw.");
        require(address(this).balance >= amount, "Contract does not have enough funds.");

        balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed.");

        emit WithdrawalAttempt(msg.sender, amount);
        emit ContractBalance(address(this).balance);
    }

    receive() external payable {}

    function getEventBets(uint256 eventId) public view returns (Bet[] memory) {
        return eventBets[eventId];
    }

    function deposit() external payable {
        require(msg.value > 0, "Must send Ether to deposit.");
    }
}
