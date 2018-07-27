pragma solidity ^0.4.19;

contract SimpleBank {
    mapping (address => uint) private balances;
    address public owner;
    event LogDepositMade(address accountAddress, uint amount);
    
    function SimpleBank() public {
        owner = msg.sender;
    }

    function deposit() public payable returns (uint) {
        require((balances[msg.sender] + msg.value) >= balances[msg.sender]);

        balances[msg.sender] += msg.value;

        LogDepositMade(msg.sender, msg.value);

        return balances[msg.sender];
    }

    function withdraw(uint withdrawAmount) public returns (uint remainingBal) {
        require(withdrawAmount <= balances[msg.sender]);
        balances[msg.sender] -= withdrawAmount;
        msg.sender.transfer(withdrawAmount);
        return balances[msg.sender];
    }

    function balance() constant public returns (uint) {
        return balances[msg.sender];
    }
}