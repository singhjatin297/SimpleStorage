// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RealEstate is Ownable {
    using SafeMath for uint256;

    struct Property {
        uint256 price;
        address owner;
        bool forSale;
        string name;
        string description;
        string location;
    }

    mapping(bytes32 => Property) public properties;
    mapping(address => bytes32[]) public propertiesByOwner;

    event PropertyRegistered(bytes32 indexed propertyId);
    event PropertySold(bytes32 indexed propertyId);

    function registerProperty(
        uint256 _price,
        string memory _name,
        string memory _description,
        string memory _location
    ) public onlyOwner returns (bytes32) {
        bytes32 propertyId = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        Property memory newProperty = Property({
            price: _price,
            owner: msg.sender,
            name: _name,
            forSale: true,
            description: _description,
            location: _location
        });

        properties[propertyId] = newProperty;
        propertiesByOwner[msg.sender].push(propertyId);

        emit PropertyRegistered(propertyId);
        return propertyId;
    }

    function buyProperty(bytes32 _propertyId) public payable {
        Property storage property = properties[_propertyId];

        require(property.forSale == true, "Property is not for sale");
        require(property.price <= msg.value, "Not enough ether sent to buy the property");

        address payable oldOwner = payable(property.owner);
        property.owner = msg.sender;
        property.forSale = false;

        (bool success, ) = oldOwner.call{value: property.price}("");
        require(success, "Transfer failed");

        emit PropertySold(_propertyId);
    }

    function getPropertiesByOwner(address _owner) public view returns (bytes32[] memory) {
        return propertiesByOwner[_owner];
    }
}