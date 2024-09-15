// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Event} from "./Event.sol";
import {EventErrors} from "./Error.sol";

contract EventManager is EventErrors {
    uint256 public totalevents;
    address public owner;
    uint256 public constant EVENT_CREATION_COST = 0.1 ether;

    struct EventStruct {
        uint256 id;
        string name;
        string eventDesc;
        uint256 cost; // in wei
        uint256 tickets;
        uint256 maxTickets;
        string date;
        string time;
        string location;
        address eventOwner;
        uint256 totalAmount; // amount of ticketsold
    }

    mapping(uint256 => EventStruct) events;

    constructor() {
        owner = msg.sender;
    }

    // function to register events
    function registerEvent(
        string memory _ipfsHash,
        string memory _name,
        string memory _eventDesc,
        uint256 _cost,
        uint256 _maxTickets,
        string memory _date,
        string memory _time,
        string memory _location
    ) external payable returns (Event newEvent) {
        require(msg.sender != address(0), ZeroAddress());
        require(msg.value >= EVENT_CREATION_COST, InsufficientPayment());

        totalevents++;
        events[totalevents] = EventStruct(
            totalevents, _name, _eventDesc, _cost, _maxTickets, _maxTickets, _date, _time, _location, msg.sender, 0
        );
        newEvent = new Event(_ipfsHash, totalevents, _name, _eventDesc, _cost, _maxTickets, _date, _time, _location);
    }

    function getEventStruct(uint256 _id) public view returns (EventStruct memory) {
        return events[_id];
    }

    function withdraw() external {
        _onlyOwner();
        (bool success,) = owner.call{value: address(this).balance}("");
        require(success, WithdrawalFailed());
    }

    function _onlyOwner() private view {
        require(msg.sender == owner, NotOwner());
    }
}
