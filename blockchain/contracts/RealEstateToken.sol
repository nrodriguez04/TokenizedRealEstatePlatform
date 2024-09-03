// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RealEstateToken is ERC20, Ownable {
    struct Property {
        string id;
        string name;
        string location;
        uint256 totalSupply;
        uint256 price; // Price per token in USDC
    }

    mapping(string => Property) public properties;
    mapping(address => mapping(string => uint256)) public userTokens;

    constructor() ERC20("RealEstateToken", "RET") Ownable(msg.sender) {}

    function addProperty(
        string memory _id,
        string memory _name,
        string memory _location,
        uint256 _totalSupply,
        uint256 _price
    ) public onlyOwner {
        require(properties[_id].totalSupply == 0, "Property already exists");
        properties[_id] = Property(_id, _name, _location, _totalSupply, _price);
        _mint(address(this), _totalSupply);
    }

    function buyTokens(string memory _propertyId, uint256 _amount) public {
        Property storage property = properties[_propertyId];
        require(property.totalSupply > 0, "Property does not exist");
        require(balanceOf(address(this)) >= _amount, "Not enough tokens available");

        uint256 cost = _amount * property.price;
        // Transfer USDC from user to contract (implementation needed)
        // transferUSDC(msg.sender, address(this), cost);

        _transfer(address(this), msg.sender, _amount);
        userTokens[msg.sender][_propertyId] += _amount;
    }

    function sellTokens(string memory _propertyId, uint256 _amount) public {
        require(userTokens[msg.sender][_propertyId] >= _amount, "Not enough tokens");

        Property storage property = properties[_propertyId];
        uint256 payout = _amount * property.price;

        _transfer(msg.sender, address(this), _amount);
        userTokens[msg.sender][_propertyId] -= _amount;

        // Transfer USDC from contract to user (implementation needed)
        // transferUSDC(address(this), msg.sender, payout);
    }

    // Additional functions for updating property details, withdrawing funds, etc.
}
