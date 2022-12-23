// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import {PullPayment} from "@openzeppelin/contracts/security/PullPayment.sol";

struct Creator {
    address CCaddress;
    uint256 price;
    address[] subscribers; // list of subscribers
    bool isCreator;
}

contract dOnlyFans is PullPayment {
    error InsufficientFunds();
    error CreatorDoesNotExist();
    error NotSubscriber();

    address[] subs;

    mapping(address => Creator) public creators;

    function createProfile(uint256 price) public returns (bool) {
        if ((creators[msg.sender].CCaddress) == msg.sender) {
            // the creator profile already exists
            return false;
        }
        address[] storage _subs = subs;
        creators[msg.sender] = Creator(msg.sender, price, _subs, true);
        return true;
    }

    function subscribe(address creatorAddress) external payable {
        Creator storage creator = creators[creatorAddress];
        if (!creator.isCreator) revert CreatorDoesNotExist();
        if (msg.value < creator.price) revert InsufficientFunds();
        creator.subscribers.push(msg.sender);
        _asyncTransfer(creatorAddress, msg.value);
    }

    function getSubscribers(
        address creatorAddress
    ) public view returns (address[] memory) {
        return creators[creatorAddress].subscribers;
    }

    function withdrawFunds() public {
        withdrawPayments(payable(msg.sender));
    }

    function unsubscribe(address creatorAddress) public {
        Creator memory creator = creators[creatorAddress];
        if (!creator.isCreator) revert CreatorDoesNotExist();
        for (uint i; i < creator.subscribers.length; i++) {
            if (msg.sender == creator.subscribers[i]) {
                delete creator.subscribers[i];
                return;
            }
        }
        revert NotSubscriber();
    }
}
