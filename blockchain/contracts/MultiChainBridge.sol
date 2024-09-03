// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MultiChainBridge is Ownable {
    mapping(uint256 => address) public chainToToken;
    mapping(uint256 => mapping(bytes32 => bool)) public processedTransactions;

    event TokensLocked(address indexed from, uint256 amount, uint256 toChainId, bytes32 transactionId);
    event TokensUnlocked(address indexed to, uint256 amount, uint256 fromChainId, bytes32 transactionId);

    constructor() Ownable(msg.sender) {}

    function setChainToken(uint256 _chainId, address _tokenAddress) public onlyOwner {
        chainToToken[_chainId] = _tokenAddress;
    }

    function lockTokens(uint256 _amount, uint256 _toChainId) public {
        require(chainToToken[_toChainId] != address(0), "Destination chain not supported");

        IERC20 token = IERC20(chainToToken[block.chainid]);
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        bytes32 transactionId = keccak256(abi.encodePacked(msg.sender, _amount, _toChainId, block.timestamp));
        emit TokensLocked(msg.sender, _amount, _toChainId, transactionId);
    }

    function unlockTokens(address _to, uint256 _amount, uint256 _fromChainId, bytes32 _transactionId) public onlyOwner {
        require(!processedTransactions[_fromChainId][_transactionId], "Transaction already processed");
        require(chainToToken[_fromChainId] != address(0), "Source chain not supported");

        IERC20 token = IERC20(chainToToken[block.chainid]);
        require(token.transfer(_to, _amount), "Transfer failed");

        processedTransactions[_fromChainId][_transactionId] = true;
        emit TokensUnlocked(_to, _amount, _fromChainId, _transactionId);
    }

    // Additional functions for managing liquidity, fees, etc.
}
