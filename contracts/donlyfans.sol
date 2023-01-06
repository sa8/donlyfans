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
    mapping(address => address) public creatorsContract;

    event NewCreatorProfileCreated(
        address creatorAddress,
        address creatorContractAddress
    );

    error CreatorAlreadyExists();

    function createProfile(uint256 price) public {
        // if ((creatorsContract[msg.sender]) != address(0)) {
        //     // the creator profile already exists
        //     revert CreatorAlreadyExists();
        // }
        Creator creator = new Creator(msg.sender, price);
        creatorsContract[msg.sender] = address(creator);
        emit NewCreatorProfileCreated(msg.sender, address(creator));
    }

    function getCreatorContractAddress(
        address creatorAddress
    ) public view returns (address) {
        return creatorsContract[creatorAddress];
    }
}

contract Creator is PullPayment {
    address public CCaddress;
    uint256 public price;
    address[] private subscribers; // list of subscribers
    bool private isCreator;
    bool public isVerified;

    struct User {
        address UserAddress;
        bool isActive;
        uint256 subscriptionStart;
        uint256 subscriptionEnd;
    }

    mapping(address => User) private users;

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

        // @dev currently doing monthly subscription, will make it configurable later
        users[msg.sender] = User(
            msg.sender,
            true,
            block.timestamp,
            block.timestamp + 30 days
        );
    }

    function getSubscribers() public view returns (address[] memory) {
        return subscribers;
    }

    function withdrawFunds() public onlyOwner {
        withdrawPayments(payable(msg.sender));
    }

    function removeSubscriber(address user) private {
        if (!isCreator) revert CreatorDoesNotExist();
        for (uint i; i < subscribers.length; i++) {
            if (user == subscribers[i]) {
                delete subscribers[i];
                return;
            }
        }
        revert NotSubscriber();
    }

    function unsubscribe() public {
        // to do: get refund if unsuscribe before the end of the period paid for
        removeSubscriber(msg.sender);
    }

    function blockUser(address user) public onlyOwner {
        removeSubscriber(user);
    }

    // check if user's subscription is still valid
    function isSubscriber(address userAddress) public view returns (bool) {
        User memory user = users[userAddress];
        if (block.timestamp > user.subscriptionEnd) {
            user.isActive = false;
            return false;
        }
        return true;
    }
}
