// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Event} from "./Event.sol";

contract EventManager {
    event CreatedMultisigWallet(address indexed, uint256 _quorum, address[] _validSigners);

    uint256 public totalevents;
    uint256 public totalTicketSold;

    struct EventStruct {
        uint256 id;
        string name;
        uint256 cost;
        uint256 tickets;
        uint256 maxTickets;
        string date;
        string time;
        string location;
    }

    mapping(uint256 => EventStruct) events;

    function list(
        string memory _name,
        uint256 _cost,
        uint256 _maxTickets,
        string memory _date,
        string memory _time,
        string memory _location
    ) external {
        totalevents++;
        events[totalevents] = EventStruct(totalevents, _name, _cost, _maxTickets, _maxTickets, _date, _time, _location);
    }

    function getEventStruct(uint256 _id) public view returns (EventStruct memory) {
        return events[_id];
    }

    // function getSeatsTaken(uint256 _id) public view returns (uint256[] memory) {
    //     return seatsTaken[_id];
    // }

    function createMultisigWallet(uint8 _quorum, address[] memory _validSigners)
        external
        returns (Event newMulSig_, uint256 length_)
    {
        //  newMulSig_ = new Event(_quorum, _validSigners);

        // multiSigClones.push(newMulSig_);

        // length_ = multiSigClones.length;

        emit CreatedMultisigWallet(msg.sender, _quorum, _validSigners);
    }

    // function getMultiSigClone(uint index) external view returns (address) {
    //     return address(multiSigClones[index]);
    // }
    // function getMultiSigClones() external view returns (MultiSig[] memory) {
    //     return multiSigClones;
    // }
}
