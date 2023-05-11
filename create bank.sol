// SPDX-License-Identifier: MIT

// Let's code a Bank !!
pragma solidity >=0.8.4; // solidity compiler version

contract Blocktrain {
    struct Account {
        address owner;
        uint256 balance;
        uint256 accountCreatedTime;
    }

    mapping(address => Account) public PNB;

    event balanceAdded(address owner, uint256 balance, uint256 timestamp);
    event withdrawalDone(address owner, uint256 balance, uint256 timestamp);

    modifier minimum() {
        require(msg.value >= 1 ether, "Doesn't follow minimum criteria");
        _;
    }

    function accountCreate() public payable {
        PNB[msg.sender].owner = msg.sender;
        PNB[msg.sender].balance = msg.value;
        PNB[msg.sender].accountCreatedTime = block.timestamp;
        emit balanceAdded(msg.sender, msg.value, block.timestamp);
    }

    function deposit(uint amount) public payable{
        PNB[msg.sender].balance += amount;
        emit balanceAdded(msg.sender, msg.value, block.timestamp);
    }

    function withdrawal(address _owner, uint amount) public payable {
        require (msg.sender == _owner);
        (bool success,) = _owner.call{value: amount}("");
        require(success);
        emit withdrawalDone(
            msg.sender,
            PNB[msg.sender].balance,
            block.timestamp
        );
    }

}    