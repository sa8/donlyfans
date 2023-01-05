// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import {PullPayment} from "@openzeppelin/contracts/security/PullPayment.sol";

/**
 * @title dOnlyFans Basic Smart Contract
 * @author Sarah Azouvi
 * @notice This contract allows a content creator (CC) to create a new profile and to set their price. Users
 * can then subscribe to the CC profile by paying the required price.
 * @dev This is meant as a "play around" contract to learn about solidity and EVM and certainly not a final product.
 */

/**
 * @notice this is the main contracts that keeps track of all the creator profiles and
 * creates a new Creator smart contract for each.
 */
contract dOnlyFans {
    mapping(address => Creator) public creators;

    function createProfile(uint256 price) public returns (bool) {
        if ((creators[msg.sender].CCaddress()) == msg.sender) {
            // the creator profile already exists
            return false;
        }
        //address[] storage _subs = subs;
        Creator creator = new Creator(msg.sender, price);
        creators[msg.sender] = creator;
        return true;
    }
}

contract Creator is PullPayment {
    address public CCaddress;
    uint256 public price;
    address[] private subscribers; // list of subscribers
    bool private isCreator;

    error InsufficientFunds();
    error CreatorDoesNotExist();
    error NotSubscriber();
    error Creator__NotOwner();

    modifier onlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != CCaddress) revert Creator__NotOwner();
        _;
    }

    constructor(address _address, uint256 _price) {
        CCaddress = _address;
        price = _price;
        isCreator = true;
    }

    function subscribe() external payable {
        // Creator storage creator = creators[creatorAddress];
        // if (!creator.isCreator) revert CreatorDoesNotExist();
        if (msg.value < price) revert InsufficientFunds();
        subscribers.push(msg.sender);
        _asyncTransfer(CCaddress, msg.value);
    }

    function getSubscribers() public view returns (address[] memory) {
        return subscribers;
    }

    function withdrawFunds() public onlyOwner {
        withdrawPayments(payable(msg.sender));
    }

    // function unsubscribe(address creatorAddress) public {
    //     Creator memory creator = creators[creatorAddress];
    //     if (!creator.isCreator) revert CreatorDoesNotExist();
    //     for (uint i; i < creator.subscribers.length; i++) {
    //         if (msg.sender == creator.subscribers[i]) {
    //             delete creator.subscribers[i];
    //             return;
    //         }
    //     }
    //     revert NotSubscriber();
    // }
}
