// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Automotive{

    struct Car{
        address owner;
        string carName;
        uint carNo;
        uint price;
        bool sold;
        address renter;
        uint rentPrice;
        bool rent;
        uint timelock;
    }
    
    Car[] public cars;

    function addCar(string memory _carName, uint _carNo, uint _price, address _renter, uint _rentPrice, uint _timelock) public{
        cars.push(Car(msg.sender, _carName, _carNo, _price, false, _renter, _rentPrice, false, _timelock));
    }

    function buyCar(uint _carNo) public payable{
        require(msg.value >= cars[_carNo].price);
        require(cars[_carNo].sold == false);
        require(cars[_carNo].rent == false);
        (bool sent,) = cars[_carNo].owner.call{value: cars[_carNo].price}("");
        require(sent);
        cars[_carNo].owner = msg.sender;
        cars[_carNo].sold = true;
    }

    function getAvailableCars() public view returns(Car[] memory){
        uint availableCarCount = 0;
        for(uint i=0; i<cars.length; i++){
            if(cars[i].sold == false)
            availableCarCount++;
        }

        Car[] memory carAvailable = new Car[](availableCarCount);
        uint index = 0;
        for(uint i=0; i<cars.length;i++){
            if(cars[i].sold == false){
                carAvailable[index] = cars[i];
                index++;
            }
        }
        return carAvailable;
    }

    function resell(uint _carNo, address payable _buyer, uint _newPrice) public payable{
        require(cars[_carNo].owner == msg.sender);
        require(cars[_carNo].sold == true);
        require(cars[_carNo].rent == false);

        cars[_carNo].sold = false;
        cars[_carNo].price = _newPrice;
        (bool sent,) = msg.sender.call{value: _newPrice}("");
        require(sent);
        cars[_carNo].owner = _buyer;
        
    }

    function carRent(uint _carNo, address payable _renter, uint _rentPrice, uint _timelock) public payable{
        require(cars[_carNo].owner == msg.sender);
        require(cars[_carNo].sold == false);
        require(cars[_carNo].rent == false);
        
        (bool sent, ) = msg.sender.call{value: _rentPrice}("");
        require(sent);
        cars[_carNo].timelock = block.timestamp + _timelock;
        cars[_carNo].rentPrice = _rentPrice;
        cars[_carNo].renter = _renter;
        cars[_carNo].rent = true;
    }

    function carReturn(uint _carNo) public{
        require(cars[_carNo].rent == true);
        require(cars[_carNo].timelock <= block.timestamp);

        cars[_carNo].rent = false;
        cars[_carNo].renter = address(0);
        cars[_carNo].timelock = 0;
    }

}