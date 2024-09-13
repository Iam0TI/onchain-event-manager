// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

contract EventInternalStruct {
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
}
