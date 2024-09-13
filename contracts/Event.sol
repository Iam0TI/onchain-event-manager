// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "./Base64.sol";
/// todo
/// add soulbound
/// add a withdrawfunction for event owner
contract Event is ERC721, ERC721URIStorage {
    error SeatAlreadyTaken(uint256 _id, uint256 _seat);
    error NotOwner();
    error InvalidEventId();
    error EventDoesNotExist();
    error InsufficientPayment();
    error InvalidSeatNumber();
    error WithdrawalFailed();
    error ZeroAddress();
    error NotEventOwner();
    error NonTransferable();

    address public owner;
    uint256 public totalevents;
    uint256 public totalSupply;

    struct EventStruct {
        uint256 id;
        string name;
        string eventDesc;
        uint256 cost;
        uint256 tickets;
        uint256 maxTickets;
        string date;
        string time;
        string location;
        address eventOwner;
        uint256 totalAmount; // amount of ticketsold
    }

    // mapping event id to eventstruct
    mapping(uint256 => EventStruct) events;

    // mapping event id to user to purchase status
    mapping(uint256 => mapping(address => bool)) public hasBought;
    // mapping event id to seat number to user
    mapping(uint256 => mapping(uint256 => address)) public seatTaken;
    // mapping event id to seat taken
    mapping(uint256 => uint256[]) seatsTaken;

    constructor() ERC721("Onchain Event Hosting", "OEH") {
        owner = msg.sender;
    }

    function getEventStruct(
        uint256 _id
    ) external view returns (EventStruct memory) {
        return events[_id];
    }

    function getSeatsTaken(
        uint256 _id
    ) external view returns (uint256[] memory) {
        return seatsTaken[_id];
    }

    // function to register events
    function registerEvent(
        string memory _name,
        string memory _eventDesc,
        uint256 _cost,
        uint256 _maxTickets,
        string memory _date,
        string memory _time,
        string memory _location,
        address _eventOwner
    ) external {
        _onlyOwner();
        require(_eventOwner != address(0), ZeroAddress());
        totalevents++;
        events[totalevents] = EventStruct(
            totalevents,
            _name,
            _eventDesc,
            _cost,
            _maxTickets,
            _maxTickets,
            _date,
            _time,
            _location,
            _eventOwner,
            0
        );
    }

    // Todo add fee and fee collector
    // allows owner to withdraw the contract funds
    function withdraw() external {
        _onlyOwner();
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, WithdrawalFailed());
    }

    function mint(uint256 _id, uint256 _seat) external payable {
        require(_id != 0, InvalidEventId());
        require(_id <= totalevents, EventDoesNotExist());
        require(msg.value >= events[_id].cost, InsufficientPayment());
        require(_seat <= events[_id].maxTickets, InvalidSeatNumber());
        require(
            seatTaken[_id][_seat] == address(0),
            SeatAlreadyTaken(_id, _seat)
        );

        string memory svg = renderSVG(events[_id].name, _seat);
        string memory imageURI = svgToImageURI(svg);
        string memory tokenURi = formatTokenURI(
            events[_id].name,
            events[_id].eventDesc,
            imageURI
        );

        events[_id].totalAmount = events[_id].totalAmount + msg.value;
        events[_id].tickets--;

        hasBought[_id][msg.sender] = true;
        seatTaken[_id][_seat] = msg.sender;

        seatsTaken[_id].push(_seat);

        totalSupply++;
        events[_id].totalAmount = events[_id].totalAmount + msg.value;
        _safeMint(msg.sender, totalSupply);
        _setTokenURI(totalSupply, tokenURi);
    }

    function svgToImageURI(
        string memory svg
    ) private pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(svg));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    /* Generates a tokenURI using Base64 string as the image */
    function formatTokenURI(
        string memory _eventName,
        string memory _eventDesc,
        string memory imageURI
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "',
                                _eventName,
                                '", "description": "',
                                _eventDesc,
                                '", "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function renderSVG(
        string memory name,
        uint256 seat
    ) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg height="512" width="512" xmlns="http://www.w3.org/2000/svg">',
                    '<path id="lineAC" d="M 30 180 q 150 -250 300 0" stroke="black" stroke-width="4" fill="blue"/>',
                    '<text style="fill:gray;font-size:25px;">',
                    '<textPath href="#lineAC" textLength="50%" startOffset="20">',
                    name,
                    '<tspan fill="none" stroke="green">Seat ID</tspan>',
                    seat,
                    "</textPath>",
                    "</text>",
                    "</svg>"
                )
            );
    }

    // ///
    // function _withdrawAbleByOwner() private view returns(uint256){
    //     return (address(this).balance * 10)/100;
    // }

    function _onlyOwner() private view {
        require(msg.sender == owner, NotOwner());
    }

    function _onlyEventOwner(uint256 _eventId) private view {
        require(msg.sender == events[_eventId].eventOwner, NotEventOwner());
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    // Soulbound implementation

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
        revert NonTransferable();
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
        revert NonTransferable();
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override(ERC721, IERC721) {
        revert NonTransferable();
    }

    function approve(
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
        revert NonTransferable();
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public virtual override(ERC721, IERC721) {
        revert NonTransferable();
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view virtual override(ERC721, IERC721) returns (bool) {
        return false;
    }

    function getApproved(
        uint256 tokenId
    ) public view virtual override(ERC721, IERC721) returns (address) {
        return address(0);
    }
}
