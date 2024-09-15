// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {EventErrors} from "./Error.sol";

/// todo events
///  event status
/// testing and bug lookout
contract Event is ERC1155, ERC1155URIStorage, EventErrors {
    address public owner;
    uint256 public totalSupply;

    string public ipfsHash;

    /**
     * @dev Struct to store event details
     */
    struct EventStruct {
        uint256 id;
        string name;
        string eventDesc;
        uint256 cost; //wei
        uint256 tickets;
        uint256 maxTickets;
        string date;
        string time;
        string location;
        address eventOwner;
        uint256 totalAmount; // Total amount of tickets sold
    }

    EventStruct public events;

    // mappinguser to purchase status
    mapping(address => bool) public hasBought;
    // mapping  seat number to user
    mapping(uint256 => address) public seatTakenBy;
    // array of seat taken
    uint256[] seatsTaken;

    /**
     * @dev Constructor to initialize the event and set up the ERC1155 token
     * @param _ipfsHash IPFS hash for the token metadata
     * @param _id Event ID
     * @param _name Event name
     * @param _eventDesc Event description
     * @param _cost Cost per ticket
     * @param _maxTickets Maximum number of tickets available
     * @param _date Event date
     * @param _time Event time
     * @param _location Event location
     */
    constructor(
        string memory _ipfsHash,
        uint256 _id,
        string memory _name,
        string memory _eventDesc,
        uint256 _cost,
        uint256 _maxTickets,
        string memory _date,
        string memory _time,
        string memory _location
    ) ERC1155("https://ipfs.io/ipfs/ipfsHash/{seatId}.json") {
        owner = msg.sender;
        ipfsHash = _ipfsHash;

        events = EventStruct({
            id: _id,
            name: _name,
            eventDesc: _eventDesc,
            cost: _cost,
            tickets: _maxTickets,
            maxTickets: _maxTickets,
            date: _date,
            time: _time,
            location: _location,
            eventOwner: msg.sender,
            totalAmount: 0
        });
    }

    // Override the URI function to provide token-specific metadata.

    function uri(
        uint256 _tokenid
    ) public view override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "https://ipfs.io/ipfs/",
                    ipfsHash,
                    "/",
                    Strings.toString(_tokenid),
                    ".json"
                )
            );
    }

    // Provide a URI for the entire contract.
    function contractURI() public view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "https://ipfs.io/ipfs/",
                    ipfsHash,
                    "/collection.json"
                )
            );
    }

    // function getEventStruct(
    //     uint256 _id
    // ) external view returns (EventStruct memory) {
    //     return events;
    // }

    function getSeatsTaken() external view returns (uint256[] memory) {
        return seatsTaken;
    }

    // Todo add fee and fee collector
    // allows owner to withdraw the contract funds
    function withdraw() external {
        _onlyOwner();
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, WithdrawalFailed());
    }

    function mint(uint256 _seat) external payable {
        // require(_id != 0, InvalidEventId());
        //require(_id <= totalevents, EventDoesNotExist());
        require(msg.value >= events.cost, InsufficientPayment());
        require(_seat <= events.maxTickets, InvalidSeatNumber());
        require(seatTakenBy[_seat] == address(0), SeatAlreadyTaken(_seat));

        events.totalAmount = events.totalAmount + msg.value;
        events.tickets--;

        hasBought[msg.sender] = true;
        seatTakenBy[_seat] = msg.sender;

        seatsTaken.push(_seat);

        totalSupply++;
        events.totalAmount = events.totalAmount + msg.value;
    }

    function _onlyOwner() private view {
        require(msg.sender == owner, NotOwner());
    }

    // The following functions are overrides required by Solidity.

    /**
     * @notice will revert. Soulbound tokens cannot be transferred.
     */
    function setApprovalForAll(
        address operator,
        bool approved
    ) public pure override {
        revert SoulboundTokenCannotBeTransferred();
    }

    /**
     * @notice will revert. Soulbound tokens cannot be transferred.
     */
    function isApprovedForAll(
        address account,
        address operator
    ) public pure override returns (bool) {
        revert SoulboundTokenCannotBeTransferred();
    }

    /**
     * @notice will revert. Soulbound tokens cannot be transferred.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        revert SoulboundTokenCannotBeTransferred();
    }

    /**
     * @notice will revert. Soulbound tokens cannot be transferred.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public pure override {
        revert SoulboundTokenCannotBeTransferred();
    }
}
