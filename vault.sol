// SPDX-License-Identifier: MIT

// Let's code a Bank !!
pragma solidity >=0.8.4; // solidity compiler version

contract Blocktrain {
    //deposit withdraw timelock

    struct vault{
        address owner;
        uint timelock;
        uint amount;
    }

    mapping(address => vault) public vaultOwner;

    function accountCreate() public {
        vaultOwner[msg.sender].owner = msg.sender;
    }

    function deposit(uint time_locked) public payable{
        vaultOwner[msg.sender].amount = msg.value;
        vaultOwner[msg.sender].timelock = block.timestamp + time_locked;
    }

    function withdraw() public payable{
        require(vaultOwner[msg.sender].owner == msg.sender );
        require(block.timestamp >= vaultOwner[msg.sender].timelock);
        (bool success,) = msg.sender.call{value:vaultOwner[msg.sender].amount}("");
        require(success);
    }

}